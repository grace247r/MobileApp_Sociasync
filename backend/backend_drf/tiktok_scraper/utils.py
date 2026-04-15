"""TikTok data scraping utilities using Apify"""

from apify_client import ApifyClient
from pathlib import Path
import os
from dotenv import load_dotenv
import logging

logger = logging.getLogger(__name__)

# Load environment variables
env_path = Path(__file__).resolve().parent.parent.parent / 'backend' / '.env'
load_dotenv(env_path)


class ApifyTikTokScraper:
    """Wrapper for Apify TikTok profile scraper"""
    
    # Apify TikTok Profile Scraper Actor ID
    # This is the correct actor ID for scraping TikTok profiles
    ACTOR_ID = "0FXVyOXXEmdGcV88a"
    
    def __init__(self):
        self.api_token = os.getenv('APIFY_API_TOKEN')
        if not self.api_token:
            raise ValueError("APIFY_API_TOKEN not found in environment variables")
        self.client = ApifyClient(self.api_token)
    
    def scrape_tiktok(self, username, results_limit=200):
        """
        Scrape TikTok profile and recent videos
        
        Args:
            username: TikTok username (without @)
            results_limit: Maximum videos to scrape (default 200)
        
        Returns:
            Dictionary with actor run info: {'id': run_id, 'defaultDatasetId': dataset_id}
        """
        try:
            # The actor expects profiles array with specific structure
            run_input = {
                "profiles": [username],
                "postsLimit": min(results_limit, 200),  # Cap at 200 for API limits
            }
            
            logger.info(f"Starting TikTok scrape for @{username}")
            
            run = self.client.actor(self.ACTOR_ID).call(run_input=run_input)
            
            return {
                'id': run['id'],
                'defaultDatasetId': run['defaultDatasetId'],
                'status': run['status'],
            }
            
        except Exception as e:
            logger.error(f"Error scraping TikTok: {str(e)}")
            raise Exception(f"Failed to start TikTok scraper: {str(e)}")
    
    def wait_for_completion(self, actor_run_id, timeout=300):
        """
        Wait for actor run to complete and return dataset ID
        
        Args:
            actor_run_id: The actor run ID to wait for
            timeout: Maximum seconds to wait (default 300)
        
        Returns:
            Dataset ID if completed successfully, None otherwise
        """
        try:
            run = self.client.actor(self.ACTOR_ID).run(actor_run_id).wait_for_finish()
            
            if run['status'] == 'SUCCEEDED':
                return run['defaultDatasetId']
            else:
                logger.error(f"Actor run failed with status: {run['status']}")
                return None
                
        except Exception as e:
            logger.error(f"Error waiting for completion: {str(e)}")
            return None
    
    def get_dataset_items(self, dataset_id):
        """
        Get items from completed actor run dataset
        
        Args:
            dataset_id: The dataset ID to retrieve items from
        
        Returns:
            List of items from the dataset
        """
        try:
            dataset = self.client.dataset(dataset_id)
            items = dataset.iterate_items()
            return list(items)
            
        except Exception as e:
            logger.error(f"Error getting dataset items: {str(e)}")
            raise Exception(f"Failed to get dataset: {str(e)}")


class EngagementCalculator:
    """Calculate engagement metrics for TikTok content"""
    
    @staticmethod
    def calculate_engagement_percentage(total_likes, total_comments, followers_count):
        """
        Calculate engagement rate as percentage
        Formula: (likes + comments) / followers * 100
        
        Args:
            total_likes: Total likes on content
            total_comments: Total comments on content
            followers_count: Current follower count
        
        Returns:
            Engagement percentage (0-100)
        """
        if followers_count <= 0:
            return 0.0
        
        engagement = ((total_likes + total_comments) / followers_count) * 100
        return min(round(engagement, 2), 100.0)
