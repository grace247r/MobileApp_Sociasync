import os
from pathlib import Path
from apify_client import ApifyClient
from django.conf import settings
from dotenv import load_dotenv

# Load environment variables from backend/.env
backend_dir = Path(__file__).resolve().parent.parent.parent  # Go up 3 levels to backend/
env_file = backend_dir / '.env'
load_dotenv(env_file)


class ApifyInstagramScraper:
    """Wrapper for Apify Instagram scraping"""

    ACTOR_ID = "shu8hvrXbJbY3Eb9W"  # Instagram Actor ID

    def __init__(self):
        api_token = os.getenv('APIFY_API_TOKEN') or getattr(settings, 'APIFY_API_TOKEN', None)
        if not api_token:
            raise ValueError(
                "APIFY_API_TOKEN not found. Set it in .env file or Django settings."
            )
        self.client = ApifyClient(api_token)

    def scrape_instagram(self, username, results_limit=200):
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

        try:
            run = self.client.actor(self.ACTOR_ID).call(run_input=run_input)
            return run
        except Exception as e:
            raise Exception(f"Apify scraping error: {str(e)}")

    def get_dataset_items(self, dataset_id):
        """
        Fetch items from Apify dataset

        Args:
            dataset_id (str): Dataset ID from run result

        Returns:
            list: List of scraped items
        """
        try:
            items = list(self.client.dataset(dataset_id).iterate_items())
            return items
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
