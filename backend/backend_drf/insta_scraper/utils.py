import os
import time
from apify_client import ApifyClient
from django.conf import settings


class ApifyInstagramScraper:
    """Wrapper for Apify Instagram scraping"""

    ACTOR_ID = "shu8hvrXbJbY3Eb9W"  # Instagram Actor ID

    def __init__(self):
        api_token = os.getenv('APIFY_API_TOKEN') or getattr(settings, 'APIFY_API_TOKEN', None)
        if not api_token:
            env_hint = getattr(settings, 'BASE_DIR', None)
            env_path = f"{env_hint}/.env" if env_hint else "backend/backend_drf/.env"
            raise ValueError(
                f"APIFY_API_TOKEN not found. Add APIFY_API_TOKEN=your_apify_token in {env_path} or Django settings."
            )
        self.client = ApifyClient(api_token)

    def scrape_instagram(self, username, results_limit=60):
        """
        Scrape Instagram data using Apify

        Args:
            username (str): Instagram username (without @)
            results_limit (int): Maximum results to fetch (1-1000)

        Returns:
            dict: Run result with defaultDatasetId
        """
        # Construct Instagram profile URL
        url = f"https://www.instagram.com/{username}/"
        
        run_input = {
            "directUrls": [url],
            "resultsType": "posts",
            "resultsLimit": results_limit,
            "searchType": "user",
            "addParentData": True,
        }

        last_error = None
        for attempt in range(1, 3):
            try:
                run = self.client.actor(self.ACTOR_ID).call(run_input=run_input)
                return run
            except Exception as e:
                last_error = e
                # Retry once for transient network/proxy blocks from Instagram.
                if attempt < 2:
                    time.sleep(2)
                    continue
                break

        raise Exception(f"Apify scraping error: {str(last_error)}")

    def get_dataset_items(self, dataset_id):
        """
        Fetch items from Apify dataset

        Args:
            dataset_id (str): Dataset ID from run result

        Returns:
            list: List of scraped items
        """
        try:
            last_error = None
            for attempt in range(1, 6):
                try:
                    items = list(self.client.dataset(dataset_id).iterate_items())
                    if items:
                        return items

                    # Some runs finish before the dataset is fully visible.
                    if attempt < 5:
                        time.sleep(2)
                        continue
                    return items
                except Exception as e:
                    last_error = e
                    if attempt < 5:
                        time.sleep(2)
                        continue
                    raise e
        except Exception as e:
            raise Exception(f"Error fetching dataset: {str(e)}")

    def get_run_status(self, run_id):
        """Get status of a specific run"""
        try:
            run = self.client.run(run_id).get()
            return run
        except Exception as e:
            raise Exception(f"Error fetching run status: {str(e)}")


class EngagementCalculator:
    """Calculate engagement metrics"""

    @staticmethod
    def calculate_engagement_percentage(total_likes, total_comments, followers_count):
        """
        Calculate engagement percentage using standard formula:
        Engagement % = ((Total Likes + Total Comments) / (Number of Posts * Followers)) * 100
        
        Args:
            total_likes (int): Total likes across all posts
            total_comments (int): Total comments across all posts
            followers_count (int): Current follower count
            
        Returns:
            float: Engagement percentage (0-100)
        """
        if followers_count == 0:
            return 0.0
        
        total_engagement = total_likes + total_comments
        if total_engagement == 0:
            return 0.0
        
        # General engagement formula
        engagement_percentage = (total_engagement / followers_count) * 100
        
        # Cap at 100% for display purposes
        return min(round(engagement_percentage, 2), 100.0)

    @staticmethod
    def calculate_average_engagement_per_post(total_likes, total_comments, posts_count):
        """
        Calculate average engagement per post
        
        Args:
            total_likes (int): Total likes
            total_comments (int): Total comments
            posts_count (int): Number of posts
            
        Returns:
            float: Average engagement per post
        """
        if posts_count == 0:
            return 0.0
        
        total_engagement = total_likes + total_comments
        return round(total_engagement / posts_count, 2)

    @staticmethod
    def calculate_estimated_reach(total_likes, total_comments):
        """Estimate reach from interactions using fixed multiplier."""
        total_interaction = (total_likes or 0) + (total_comments or 0)
        return int(total_interaction * 20)
