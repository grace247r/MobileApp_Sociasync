from notifications.models import Notification
from django.contrib.auth import get_user_model

User = get_user_model()


class ActivityNotificationService:
    """Service to create notifications when scraper data shows activity changes"""

    @staticmethod
    def check_and_notify_instagram(user, old_stats, new_stats, platform='Instagram'):
        """
        Compare old and new Instagram stats and create notifications
        
        Args:
            user: User object
            old_stats: Previous InstagramStats object (or None if first scrape)
            new_stats: New InstagramStats object
            platform: Platform name for notification message
        """
        if not old_stats:
            # First scrape, no comparison
            return

        changes = {
            'new_followers': new_stats.followers_count - old_stats.followers_count,
            'new_likes': new_stats.total_likes - old_stats.total_likes,
            'new_comments': new_stats.total_comments - old_stats.total_comments,
        }

        # Create notifications for positive changes
        if changes['new_followers'] > 0:
            Notification.objects.create(
                recipient=user,
                notif_type='followers',
                title=f'New Followers on {platform}! 🎉',
                message=f'You gained {changes["new_followers"]} new followers! Now at {new_stats.followers_count} followers.',
            )

        if changes['new_likes'] > 0 or changes['new_comments'] > 0:
            engagement_change = changes['new_likes'] + changes['new_comments']
            Notification.objects.create(
                recipient=user,
                notif_type='engagement',
                title=f'Your posts have activity! 📈',
                message=f'You got {changes["new_likes"]} new likes and {changes["new_comments"]} new comments since last check.',
            )

        # Combined activity notification
        if changes['new_followers'] > 0 or changes['new_likes'] > 0 or changes['new_comments'] > 0:
            total_engagement = changes['new_likes'] + changes['new_comments']
            Notification.objects.create(
                recipient=user,
                notif_type='activity',
                title=f'{platform} Activity Update ✨',
                message=f'Your {platform} is growing! +{changes["new_followers"]} followers, +{total_engagement} total engagement.',
            )

    @staticmethod
    def check_and_notify_tiktok(user, old_stats, new_stats, platform='TikTok'):
        """
        Compare old and new TikTok stats and create notifications
        
        Args:
            user: User object
            old_stats: Previous TikTokStats object (or None if first scrape)
            new_stats: New TikTokStats object
            platform: Platform name for notification message
        """
        if not old_stats:
            # First scrape, no comparison
            return

        changes = {
            'new_followers': new_stats.followers_count - old_stats.followers_count,
            'new_likes': new_stats.total_likes - old_stats.total_likes,
            'new_comments': new_stats.total_comments - old_stats.total_comments,
            'new_views': new_stats.total_views - old_stats.total_views,
        }

        # Create notifications for positive changes
        if changes['new_followers'] > 0:
            Notification.objects.create(
                recipient=user,
                notif_type='followers',
                title=f'New Followers on {platform}! 🎉',
                message=f'You gained {changes["new_followers"]} new followers! Now at {new_stats.followers_count} followers.',
            )

        if changes['new_likes'] > 0 or changes['new_comments'] > 0 or changes['new_views'] > 0:
            engagement_change = changes['new_likes'] + changes['new_comments']
            Notification.objects.create(
                recipient=user,
                notif_type='engagement',
                title=f'Your videos are going viral! 📈',
                message=f'You got {changes["new_likes"]} new likes, {changes["new_comments"]} new comments, and {changes["new_views"]} new views!',
            )

        # Combined activity notification
        if changes['new_followers'] > 0 or changes['new_likes'] > 0 or changes['new_comments'] > 0:
            total_engagement = changes['new_likes'] + changes['new_comments']
            Notification.objects.create(
                recipient=user,
                notif_type='activity',
                title=f'{platform} Activity Update ✨',
                message=f'Your {platform} is blowing up! +{changes["new_followers"]} followers, +{total_engagement} engagement, +{changes["new_views"]} views.',
            )
