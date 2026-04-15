from rest_framework.decorators import api_view
from rest_framework.decorators import permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.db import models
from django.utils import timezone

from insta_scraper.models import InstagramPost, InstagramProfile, InstagramStats
from tiktok_scraper.models import TikTokProfile, TikTokStats, TikTokVideo
from .services.ai_service import AIServiceError, call_ai


def _format_dt(value):
    if not value:
        return 'unknown'

    try:
        return timezone.localtime(value).strftime('%Y-%m-%d %H:%M')
    except Exception:
        try:
            return value.strftime('%Y-%m-%d %H:%M')
        except Exception:
            return str(value)


def _wants_account_analytics(message):
    lowered = message.lower()
    keywords = [
        'analisis',
        'analysis',
        'analytics',
        'engagement',
        'reach',
        'followers',
        'follower',
        'akun saya',
        'account analysis',
        'performance',
        'stat',
        'stats',
        'growth',
    ]
    return any(keyword in lowered for keyword in keywords)


def _wants_content_ideas(message):
    lowered = message.lower()
    keywords = [
        'ide konten',
        'content idea',
        'content ideas',
        'ide posting',
        'saran konten',
        'rekomendasi konten',
        'best post',
        'konten apa',
        'post apa',
        'what should i post',
        'what content',
        'viral',
        'trending',
    ]
    return any(keyword in lowered for keyword in keywords)


def _build_account_context(user):
    sections = []

    if getattr(user, 'instagram_connected', False) and getattr(user, 'instagram_username', None):
        latest_instagram = InstagramStats.objects.filter(user=user).order_by('-recorded_at').first()
        if latest_instagram:
            sections.append(
                'Instagram: '
                f'username=@{user.instagram_username}, '
                f'followers={latest_instagram.followers_count}, '
                f'engagement={latest_instagram.engagement_percentage:.2f}%, '
                f'posts={latest_instagram.total_posts}, '
                f'likes={latest_instagram.total_likes}, '
                f'comments={latest_instagram.total_comments}, '
                f'avg_likes_per_post={latest_instagram.average_likes_per_post:.2f}, '
                f'avg_comments_per_post={latest_instagram.average_comments_per_post:.2f}, '
                f'last_recorded={_format_dt(latest_instagram.recorded_at)}'
            )
        else:
            sections.append(
                f'Instagram: username=@{user.instagram_username}, connected but no stats have been scraped yet.'
            )

    if getattr(user, 'tiktok_connected', False) and getattr(user, 'tiktok_username', None):
        latest_tiktok = TikTokStats.objects.filter(user=user).order_by('-recorded_at').first()
        if latest_tiktok:
            sections.append(
                'TikTok: '
                f'username=@{user.tiktok_username}, '
                f'followers={latest_tiktok.followers_count}, '
                f'engagement={latest_tiktok.engagement_percentage:.2f}%, '
                f'videos={latest_tiktok.total_videos}, '
                f'likes={latest_tiktok.total_likes}, '
                f'comments={latest_tiktok.total_comments}, '
                f'views={latest_tiktok.total_views}, '
                f'avg_likes_per_video={latest_tiktok.average_likes_per_video:.2f}, '
                f'avg_views_per_video={latest_tiktok.average_views_per_video:.2f}, '
                f'last_recorded={_format_dt(latest_tiktok.recorded_at)}'
            )
        else:
            sections.append(
                f'TikTok: username=@{user.tiktok_username}, connected but no stats have been scraped yet.'
            )

    if not sections:
        return 'No connected social analytics data is available for this user yet.'

    return '\n'.join(sections)


def _truncate_text(value, limit=120):
    text = str(value or '').strip()
    if len(text) <= limit:
        return text
    return f"{text[:limit].rstrip()}..."


def _build_best_posts_context(user, limit=2):
    sections = []

    instagram_profile = InstagramProfile.objects.filter(user=user).first()
    if instagram_profile is not None:
        instagram_posts = list(
            InstagramPost.objects.filter(profile=instagram_profile)
            .annotate(engagement=models.F('likes') + models.F('comments_count'))
            .order_by('-engagement', '-post_timestamp')[:limit]
        )
        if instagram_posts:
            post_lines = []
            for post in instagram_posts:
                engagement = (post.likes or 0) + (post.comments_count or 0)
                post_lines.append(
                    f'- Instagram post: engagement={engagement}, likes={post.likes}, comments={post.comments_count}, caption="{_truncate_text(post.caption, 100)}"'
                )
            sections.append('Top Instagram posts:\n' + '\n'.join(post_lines))

    tiktok_profile = TikTokProfile.objects.filter(user=user).first()
    if tiktok_profile is not None:
        tiktok_videos = list(
            TikTokVideo.objects.filter(profile=tiktok_profile)
            .annotate(engagement=models.F('likes') + models.F('comments_count') + models.F('views'))
            .order_by('-engagement', '-video_timestamp')[:limit]
        )
        if tiktok_videos:
            video_lines = []
            for video in tiktok_videos:
                engagement = (video.likes or 0) + (video.comments_count or 0) + (video.views or 0)
                video_lines.append(
                    f'- TikTok video: engagement={engagement}, likes={video.likes}, comments={video.comments_count}, views={video.views}, caption="{_truncate_text(video.caption, 100)}"'
                )
            sections.append('Top TikTok videos:\n' + '\n'.join(video_lines))

    if not sections:
        return 'No best-post data is available yet. Ask the user to run a scrape first.'

    return '\n'.join(sections)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def chat(request):
    message = str(request.data.get("message", "")).strip()
    if not message:
        return Response(
            {"error": "Message tidak boleh kosong."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    history_raw = request.data.get("history", [])
    history = history_raw if isinstance(history_raw, list) else []
    history = history[-20:]

    conversation = ""

    for msg in history:
        if not isinstance(msg, dict):
            continue
        content = str(msg.get("content", "")).strip()
        if not content:
            continue
        role = "User" if str(msg.get("role", "")).lower() == "user" else "Assistant"
        conversation += f"{role}: {content}\n"

    conversation += f"User: {message}\nAssistant:"

    analytics_section = ''
    best_posts_section = ''
    if _wants_account_analytics(message):
        account_context = _build_account_context(request.user)
        analytics_section = f"""

Account analytics context:
{account_context}

Rules:
- Respond naturally like a human
- Keep it concise
- Continue the conversation smoothly
- If context exists, USE IT
- If account analytics context is provided, answer based on it and do not invent missing metrics
- If the user asks for account analysis but no analytics data exists, explain that no scraped stats are available yet
"""

    if _wants_content_ideas(message):
        best_posts_context = _build_best_posts_context(request.user)
        best_posts_section = f"""

Best-performing post context:
{best_posts_context}

Rules for content ideas:
- Suggest ideas inspired by the user's strongest posts, but do not copy them verbatim
- Look for patterns in theme, format, hook, and caption style
- Give practical next-step ideas the user can post soon
- If best-post data is missing, say so and give general ideas instead
"""

    prompt = f"""
You are a smart AI assistant.

Conversation:
{conversation}
{analytics_section}
{best_posts_section}
"""

    try:
        reply = call_ai(prompt, mode="chat")
    except AIServiceError as e:
        return Response(
            {"error": e.message},
            status=e.status_code,
        )

    return Response({
        "reply": reply
    })