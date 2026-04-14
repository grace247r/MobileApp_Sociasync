from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from datetime import datetime
from django.db import transaction, models
from django.utils.dateparse import parse_date

from .models import InstagramProfile, InstagramPost, ScrapeJob, InstagramStats
from .serializers import (
    InstagramProfileSerializer,
    ScrapeJobSerializer,
    ConnectInstagramSerializer,
    InstagramStatsSerializer,
    InstagramPostSerializer,
)
from .utils import ApifyInstagramScraper, EngagementCalculator


class InstagramViewSet(viewsets.ViewSet):
    """Handle Instagram operations"""
    permission_classes = [IsAuthenticated]

    def _extract_post_image_url(self, item):
        """Pick the best available cover image URL from Apify post payload."""
        if not isinstance(item, dict):
            return ''

        candidates = [
            item.get('displayUrl'),
            item.get('imageUrl'),
            item.get('thumbnailSrc'),
            item.get('thumbnailUrl'),
        ]

        resources = item.get('displayResourceUrls')
        if isinstance(resources, list):
            candidates.extend(resources)

        images = item.get('images')
        if isinstance(images, list):
            for image in images:
                if isinstance(image, dict):
                    candidates.append(image.get('url'))
                    candidates.append(image.get('displayUrl'))
                elif isinstance(image, str):
                    candidates.append(image)

        for value in candidates:
            if isinstance(value, str) and value.strip():
                return value.strip()
        return ''

    def _extract_post_video_url(self, item):
        """Extract the best available video URL from Apify post payload."""
        if not isinstance(item, dict):
            return ''

        candidates = [
            item.get('videoUrl'),
            item.get('video_url'),
        ]
        for value in candidates:
            if isinstance(value, str) and value.strip():
                return value.strip()
        return ''

    @action(detail=False, methods=['post'])
    def connect_username(self, request):
        """
        Connect Instagram username to user account
        
        Request body:
        {
            "instagram_username": "username_or_@username"
        }
        """
        serializer = ConnectInstagramSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        username = serializer.validated_data['instagram_username']
        user = request.user

        try:
            # Update user with Instagram username
            user.instagram_username = username
            user.instagram_connected = True
            user.save()

            return Response(
                {
                    'message': 'Instagram username connected successfully',
                    'instagram_username': username,
                },
                status=status.HTTP_200_OK
            )
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=False, methods=['post'])
    def trigger_scrape(self, request):
        """
        Manually trigger Instagram scrape for connected user
        
        Request body (optional):
        {
            "results_limit": 200
        }
        """
        user = request.user
        
        # Check if user has connected Instagram username
        if not user.instagram_username:
            return Response(
                {'error': 'Please connect your Instagram username first'},
                status=status.HTTP_400_BAD_REQUEST
            )

        raw_limit = request.data.get('results_limit', 200)
        try:
            results_limit = int(raw_limit)
        except (TypeError, ValueError):
            results_limit = 200
        results_limit = max(1, min(results_limit, 1000))

        scrape_job = None
        
        try:
            # Extract username
            username = user.instagram_username.lstrip('@').lower()

            # Keep one profile per user and update username/url if needed.
            url = f"https://www.instagram.com/{username}/"
            profile, _ = InstagramProfile.objects.update_or_create(
                user=user,
                defaults={
                    'username': username,
                    'url': url,
                },
            )

            # Create scrape job
            scrape_job = ScrapeJob.objects.create(
                user=user,
                profile=profile,
                status='running'
            )

            # Initialize Apify scraper
            scraper = ApifyInstagramScraper()

            # Start scraping
            run = scraper.scrape_instagram(
                username=username,
                results_limit=results_limit
            )

            # Update job with Apify run ID
            scrape_job.apify_run_id = run['id']
            scrape_job.save()

            # Get and process dataset
            stats_data = self._process_dataset(run['defaultDatasetId'], scrape_job, profile, user)

            # Update job status
            scrape_job.status = 'completed'
            scrape_job.completed_at = datetime.now()
            scrape_job.save()

            # Update user's last scraped time
            user.last_scraped = datetime.now()
            user.save()

            return Response(
                {
                    'message': 'Scraping completed successfully',
                    'job_id': scrape_job.id,
                    'profile_id': profile.id,
                    'posts_scraped': stats_data['posts_count'],
                    'total_likes': stats_data['total_likes'],
                    'total_comments': stats_data['total_comments'],
                    'estimated_reach': EngagementCalculator.calculate_estimated_reach(
                        stats_data['total_likes'],
                        stats_data['total_comments'],
                    ),
                    'followers_count': profile.followers,
                    'engagement_percentage': scrape_job.engagement_percentage,
                },
                status=status.HTTP_201_CREATED
            )

        except Exception as e:
            if scrape_job is not None:
                scrape_job.status = 'failed'
                scrape_job.error_message = str(e)
                scrape_job.completed_at = datetime.now()
                scrape_job.save()

            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=False, methods=['get'])
    def dashboard(self, request):
        """
        Get dashboard stats for current user
        
        Returns latest Instagram stats, follower count, engagement percentage, and total posts
        """
        user = request.user

        if not user.instagram_username or not user.instagram_connected:
            return Response(
                {
                    'instagram_connected': False,
                    'message': 'Please connect your Instagram username'
                },
                status=status.HTTP_200_OK
            )

        try:
            # Get latest stats
            latest_stats = InstagramStats.objects.filter(
                user=user
            ).order_by('-recorded_at').first()

            if not latest_stats:
                return Response(
                    {
                        'instagram_connected': True,
                        'instagram_username': user.instagram_username,
                        'message': 'No data yet. Run your first scrape to see stats.',
                        'latest_stats': None,
                    },
                    status=status.HTTP_200_OK
                )

            serializer = InstagramStatsSerializer(latest_stats)
            
            return Response({
                'instagram_connected': True,
                'instagram_username': user.instagram_username,
                'last_scraped': user.last_scraped,
                'latest_stats': serializer.data,
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=False, methods=['get'])
    def stats_history(self, request):
        """Get historical stats for the current user"""
        limit = request.query_params.get('limit', 10)
        start_date = parse_date(request.query_params.get('start_date') or '')
        end_date = parse_date(request.query_params.get('end_date') or '')
        
        try:
            limit = int(limit)
        except (ValueError, TypeError):
            limit = 10

        if request.query_params.get('start_date') and start_date is None:
            return Response(
                {'error': 'Invalid start_date format. Use YYYY-MM-DD.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if request.query_params.get('end_date') and end_date is None:
            return Response(
                {'error': 'Invalid end_date format. Use YYYY-MM-DD.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        stats_qs = InstagramStats.objects.filter(user=request.user)
        if start_date is not None:
            stats_qs = stats_qs.filter(recorded_at__date__gte=start_date)
        if end_date is not None:
            stats_qs = stats_qs.filter(recorded_at__date__lte=end_date)

        stats = stats_qs.order_by('-recorded_at')[:limit]
        
        serializer = InstagramStatsSerializer(stats, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def best_posts(self, request):
        """
        Get best performing posts by engagement (likes + comments)
        
        Query params:
        - limit: number of posts to return (default: 6)
        """
        limit = request.query_params.get('limit', 6)
        
        try:
            limit = int(limit)
        except (ValueError, TypeError):
            limit = 6

        try:
            # Get user's Instagram profile
            profile = InstagramProfile.objects.get(user=request.user)

            base_qs = InstagramPost.objects.filter(
                profile=profile
            ).annotate(
                engagement=models.F('likes') + models.F('comments_count')
            )

            # Prioritize posts that have image cover URL, then fill remaining slots.
            posts_with_image = base_qs.exclude(image_url__isnull=True).exclude(
                image_url__exact=''
            ).order_by('-engagement')[:limit]

            posts = list(posts_with_image)
            if len(posts) < limit:
                existing_ids = [post.id for post in posts]
                fallback_posts = base_qs.exclude(id__in=existing_ids).order_by(
                    '-engagement'
                )[: max(limit - len(posts), 0)]
                posts.extend(fallback_posts)
            
            # Serialize posts
            serializer = InstagramPostSerializer(posts, many=True)
            
            return Response({
                'profile_username': profile.username,
                'profile_pic': profile.profile_pic,
                'posts': serializer.data
            })
            
        except InstagramProfile.DoesNotExist:
            return Response(
                {'error': 'Instagram profile not found. Please connect your Instagram account first.'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @transaction.atomic
    def _process_dataset(self, dataset_id, scrape_job, profile, user):
        """Process Apify dataset and save to database"""
        try:
            scraper = ApifyInstagramScraper()
            items = scraper.get_dataset_items(dataset_id)

            posts_count = 0
            total_likes = 0
            total_comments = 0
            profile_data_found = False

            for item in items:
                # Handle profile data (merged with first post)
                if 'profilePicUrl' in item and not profile_data_found:
                    profile.profile_pic = item.get('profilePicUrl')
                    profile.biography = item.get('biography', '')
                    profile.followers = item.get('followersCount', 0)
                    profile.following = item.get('followsCount', 0)
                    profile.posts_count = item.get('postsCount', 0)
                    profile.is_verified = item.get('verified', False)
                    profile.save()
                    profile_data_found = True

                # Handle post data (all items contain post data)
                if 'url' in item and 'shortCode' in item:
                    image_url = self._extract_post_image_url(item)
                    post_data = {
                        'post_id': item.get('shortCode', ''),
                        'post_url': item.get('url', ''),
                        'caption': item.get('caption', ''),
                        'image_url': image_url,
                        'video_url': self._extract_post_video_url(item),
                        'likes': item.get('likesCount') or 0,
                        'comments_count': item.get('commentsCount') or 0,
                        'shares': 0,
                        'post_timestamp': item.get('timestamp', datetime.now()),
                    }

                    total_likes += post_data['likes']
                    total_comments += post_data['comments_count']
                    posts_count += 1

                    # Create or update post
                    InstagramPost.objects.update_or_create(
                        post_id=post_data['post_id'],
                        profile=profile,
                        defaults=post_data
                    )

            # Calculate engagement percentage
            engagement_calculator = EngagementCalculator()
            engagement_percentage = engagement_calculator.calculate_engagement_percentage(
                total_likes=total_likes,
                total_comments=total_comments,
                followers_count=profile.followers
            )

            # Update scrape job with engagement
            scrape_job.engagement_percentage = engagement_percentage
            scrape_job.posts_scraped = posts_count
            scrape_job.save()

            # Create stats snapshot for dashboard (always create new record for history)
            InstagramStats.objects.create(
                user=user,
                profile=profile,
                total_posts=profile.posts_count,
                followers_count=profile.followers,
                engagement_percentage=engagement_percentage,
                total_likes=total_likes,
                total_comments=total_comments,
                average_likes_per_post=total_likes / profile.posts_count if profile.posts_count > 0 else 0,
                average_comments_per_post=total_comments / profile.posts_count if profile.posts_count > 0 else 0,
            )
            
            # Return metrics for response
            return {
                'posts_count': posts_count,
                'total_likes': total_likes,
                'total_comments': total_comments,
            }

        except Exception as e:
            raise Exception(f"Error processing dataset: {str(e)}")
