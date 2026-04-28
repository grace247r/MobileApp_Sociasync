from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from datetime import datetime
from django.contrib.auth import get_user_model
from django.db import IntegrityError
from django.db import transaction, models
from django.utils import timezone
import logging

logger = logging.getLogger(__name__)
User = get_user_model()

from .models import TikTokProfile, TikTokVideo, TikTokScrapeJob, TikTokStats
from .serializers import (
    TikTokProfileSerializer,
    TikTokScrapeJobSerializer,
    ConnectTikTokSerializer,
    TikTokStatsSerializer,
    TikTokVideoSerializer,
)
from .utils import ApifyTikTokScraper, EngagementCalculator
from notifications.services import ActivityNotificationService


class TikTokViewSet(viewsets.ViewSet):
    """Handle TikTok operations"""
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['post'])
    def connect_username(self, request):
        """
        Connect TikTok username to user account
        
        Request body:
        {
            "tiktok_username": "@username"
        }
        """
        serializer = ConnectTikTokSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        username = serializer.validated_data['tiktok_username']
        user = request.user

        if User.objects.filter(tiktok_username__iexact=username).exclude(pk=user.pk).exists():
            return Response(
                {'error': 'TikTok username already used by another account.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        try:
            # Update user's TikTok username
            user.tiktok_username = username
            user.tiktok_connected = True
            user.save()
            
            return Response(
                {
                    'message': 'TikTok username connected successfully',
                    'tiktok_username': username,
                },
                status=status.HTTP_200_OK
            )
        
        except IntegrityError:
            return Response(
                {'error': 'TikTok username already used by another account.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['post'])
    def trigger_scrape(self, request):
        """
        Manually trigger TikTok scrape for connected user
        
        Request body (optional):
        {
            "results_limit": 200
        }
        """
        user = request.user
        
        # Check if user has connected TikTok username
        if not user.tiktok_username:
            return Response(
                {'error': 'Please connect your TikTok username first'},
                status=status.HTTP_400_BAD_REQUEST
            )

        results_limit = request.data.get('results_limit', 200)
        scrape_job = None
        
        try:
            # Extract username
            username = user.tiktok_username.lstrip('@').lower()

            # Get or create profile
            url = f"https://www.tiktok.com/@{username}"
            try:
                profile, _ = TikTokProfile.objects.update_or_create(
                    user=user,
                    defaults={
                        'username': username,
                        'url': url,
                    },
                )
            except IntegrityError:
                return Response(
                    {'error': 'TikTok profile already exists for this account or URL is already used.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Create scrape job
            scrape_job = TikTokScrapeJob.objects.create(
                user=user,
                profile=profile,
                status='running'
            )

            # Initialize Apify scraper
            scraper = ApifyTikTokScraper()

            # Start scraping
            run = scraper.scrape_tiktok(
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
            scrape_job.completed_at = timezone.now()
            scrape_job.save()

            # Update user's last scraped time
            user.last_scraped = timezone.now()
            user.save()

            # Build response with warning if no videos
            response_data = {
                'message': 'Scraping completed' if stats_data['videos_count'] > 0 else 'Scraping completed but no videos found - profile may be restricted',
                'job_id': scrape_job.id,
                'profile_id': profile.id,
                'videos_scraped': stats_data['videos_count'],
                'total_likes': stats_data['total_likes'],
                'total_views': stats_data['total_views'],
                'followers_count': stats_data['followers_count'],
                'engagement_percentage': stats_data['engagement_percentage'],
            }
            
            return Response(response_data, status=status.HTTP_201_CREATED)

        except Exception as e:
            if scrape_job is not None:
                scrape_job.status = 'failed'
                scrape_job.error_message = str(e)
                scrape_job.completed_at = timezone.now()
                scrape_job.save()
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['get'])
    def dashboard(self, request):
        """Get latest TikTok stats for connected profile"""
        user = request.user

        if not user.tiktok_username or not user.tiktok_connected:
            return Response(
                {
                    'tiktok_connected': False,
                    'message': 'Please connect your TikTok username',
                },
                status=status.HTTP_200_OK,
            )

        try:
            latest_stats = TikTokStats.objects.filter(
                user=user,
            ).order_by('-recorded_at').first()

            if not latest_stats:
                return Response(
                    {
                        'tiktok_connected': True,
                        'tiktok_username': user.tiktok_username,
                        'message': 'No data yet. Run your first scrape to see stats.',
                        'latest_stats': None,
                    },
                    status=status.HTTP_200_OK,
                )

            serializer = TikTokStatsSerializer(latest_stats)
            return Response(
                {
                    'tiktok_connected': True,
                    'tiktok_username': user.tiktok_username,
                    'last_scraped': user.last_scraped,
                    'latest_stats': serializer.data,
                },
                status=status.HTTP_200_OK,
            )

        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
    @action(detail=False, methods=['get'])
    def stats_history(self, request):
        """Get historical stats for the current user"""
        limit = request.query_params.get('limit', 10)
        
        try:
            limit = int(limit)
        except (ValueError, TypeError):
            limit = 10

        stats = TikTokStats.objects.filter(
            user=request.user
        ).order_by('-recorded_at')[:limit]
        
        serializer = TikTokStatsSerializer(stats, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def best_videos(self, request):
        """
        Get best performing videos by engagement (likes + comments + views)
        
        Query params:
        - limit: number of videos to return (default: 6)
        """
        limit = request.query_params.get('limit', 6)
        
        try:
            limit = int(limit)
        except (ValueError, TypeError):
            limit = 6

        try:
            profile = TikTokProfile.objects.filter(user=request.user).first()
            if profile is None:
                return Response(
                    {
                        'profile_username': request.user.tiktok_username or '',
                        'profile_pic': '',
                        'videos': [],
                    },
                    status=status.HTTP_200_OK,
                )

            videos = TikTokVideo.objects.filter(
                profile=profile
            ).annotate(
                engagement=models.F('likes') + models.F('comments_count') + models.F('views')
            ).order_by('-engagement')[:limit]

            serializer = TikTokVideoSerializer(videos, many=True)

            return Response(
                {
                    'profile_username': profile.username,
                    'profile_pic': profile.profile_pic,
                    'videos': serializer.data,
                },
                status=status.HTTP_200_OK,
            )

        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['get'])
    def jobs(self, request):
        """Get scrape job history"""
        limit = request.query_params.get('limit', 10)
        
        try:
            limit = int(limit)
        except (ValueError, TypeError):
            limit = 10

        jobs = TikTokScrapeJob.objects.filter(
            user=request.user
        ).order_by('-started_at')[:limit]
        
        serializer = TikTokScrapeJobSerializer(jobs, many=True)
        return Response(serializer.data)

    @transaction.atomic
    def _process_dataset(self, dataset_id, scrape_job, profile, user):
        """Process Apify dataset and save to database"""
        try:
            scraper = ApifyTikTokScraper()
            items = scraper.get_dataset_items(dataset_id)

            logger.info(f"TikTok scrape dataset returned {len(items)} items")
            if len(items) > 0:
                logger.info(f"First item keys: {list(items[0].keys())}")
                logger.info(f"First item sample: {str(items[0])[:500]}")

            # Process dataset items
            videos_count = 0
            total_likes = 0
            total_comments = 0
            total_views = 0
            total_shares = 0
            profile_data_found = False

            for item in items:
                # Extract profile data from authorMeta (same on every video, so only extract once)
                if 'authorMeta' in item and not profile_data_found:
                    author = item['authorMeta']
                    profile.profile_pic = author.get('avatar', '')
                    profile.biography = author.get('signature', '')
                    profile.followers = author.get('fans', 0)
                    profile.following = author.get('following', 0)
                    profile.videos_count = author.get('video', 0)
                    profile.likes_count = author.get('heart', 0)
                    profile.is_verified = author.get('verified', False)
                    profile.save()
                    profile_data_found = True

                # Handle video data - every item is a video
                if 'id' in item:
                    # Get thumbnail from videoMeta coverUrl
                    thumbnail_url = ''
                    if 'videoMeta' in item and item['videoMeta']:
                        video_meta = item['videoMeta']
                        if isinstance(video_meta, dict) and 'coverUrl' in video_meta:
                            thumbnail_url = video_meta['coverUrl']
                    
                    # Extract engagement counts with fallbacks for field names
                    likes = item.get('diggCount', item.get('likes', 0))
                    comments = item.get('commentCount', item.get('comments', 0))
                    shares = item.get('shareCount', item.get('shares', 0))
                    views = item.get('playCount', item.get('views', 0))
                    
                    video_data = {
                        'video_id': str(item.get('id', '')),
                        'video_url': item.get('webVideoUrl', ''),
                        'caption': item.get('text', ''),
                        'thumbnail_url': thumbnail_url,
                        'likes': likes,
                        'comments_count': comments,
                        'shares': shares,
                        'views': views,
                        'video_timestamp': timezone.now(),
                    }

                    total_likes += video_data['likes']
                    total_comments += video_data['comments_count']
                    total_views += video_data['views']
                    total_shares += video_data['shares']
                    videos_count += 1
                    
                    logger.debug(f"Processing video {video_data['video_id']}: likes={likes}, comments={comments}, views={views}")

                    # Create or update video
                    TikTokVideo.objects.update_or_create(
                        video_id=video_data['video_id'],
                        profile=profile,
                        defaults=video_data
                    )
                else:
                    logger.warning(f"Item missing 'id' field: {str(item)[:200]}")

            # Calculate engagement percentage
            engagement_calculator = EngagementCalculator()
            engagement_percentage = engagement_calculator.calculate_engagement_percentage(
                total_likes=total_likes,
                total_comments=total_comments,
                followers_count=profile.followers
            )

            logger.info(
                f"TikTok stats summary: videos={videos_count}, likes={total_likes}, "
                f"comments={total_comments}, views={total_views}, "
                f"followers={profile.followers}, engagement={engagement_percentage}%"
            )

            # Update scrape job with engagement
            scrape_job.engagement_percentage = engagement_percentage
            scrape_job.videos_scraped = videos_count
            scrape_job.save()

            # Get previous stats for comparison
            previous_stats = TikTokStats.objects.filter(
                user=user,
                profile=profile
            ).order_by('-recorded_at').first()

            # Create stats snapshot for dashboard (always create new record for history)
            new_stats = TikTokStats.objects.create(
                user=user,
                profile=profile,
                total_videos=profile.videos_count,
                followers_count=profile.followers,
                engagement_percentage=engagement_percentage,
                total_likes=total_likes,
                total_comments=total_comments,
                total_views=total_views,
                total_shares=total_shares,
                average_likes_per_video=total_likes / videos_count if videos_count > 0 else 0,
                average_views_per_video=total_views / videos_count if videos_count > 0 else 0,
            )

            # Check for activity changes and create notifications
            ActivityNotificationService.check_and_notify_tiktok(
                user=user,
                old_stats=previous_stats,
                new_stats=new_stats,
                platform='TikTok'
            )
            
            # Return metrics for response
            return {
                'videos_count': videos_count,
                'total_likes': total_likes,
                'total_comments': total_comments,
                'total_views': total_views,
                'engagement_percentage': engagement_percentage,
                'followers_count': profile.followers,
            }

        except Exception as e:
            raise Exception(f"Error processing dataset: {str(e)}")
