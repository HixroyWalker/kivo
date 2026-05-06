#!/usr/bin/env python3
"""KiVo Archive Sync
Moves IDs to Archive storage class ($0.0012/GB) after 30 days.
"""

import logging
import sys
from datetime import datetime, timedelta

try:
    from google.cloud import storage
except ImportError:
    print('Error: google-cloud-storage is required. Install with: pip install google-cloud-storage')
    sys.exit(1)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

ARCHIVE_THRESHOLD_DAYS = 30
STORAGE_CLASS_FROM = 'STANDARD'
STORAGE_CLASS_TO = 'ARCHIVE'


def run_sync(bucket_name: str = None):
    """Archive old security files from standard to archive storage class.
    
    Args:
        bucket_name: GCS bucket name. If None, uses KIVO_BACKUP_BUCKET env var.
    """
    try:
        if not bucket_name:
            import os
            bucket_name = os.getenv('KIVO_BACKUP_BUCKET')
            if not bucket_name:
                logger.error('Bucket name not provided and KIVO_BACKUP_BUCKET env var not set')
                return False
        
        client = storage.Client()
        bucket = client.bucket(bucket_name)
        
        threshold_date = datetime.utcnow() - timedelta(days=ARCHIVE_THRESHOLD_DAYS)
        
        logger.info(f'Moving old security files to {STORAGE_CLASS_TO} tier...')
        logger.info(f'Threshold date: {threshold_date}')
        
        archived_count = 0
        error_count = 0
        
        for blob in bucket.list_blobs():
            try:
                # Check if blob was created before threshold
                if blob.time_created and blob.time_created.replace(tzinfo=None) < threshold_date:
                    if blob.storage_class != STORAGE_CLASS_TO:
                        logger.info(f'Archiving: {blob.name}')
                        blob.storage_class = STORAGE_CLASS_TO
                        blob.patch()
                        archived_count += 1
            except Exception as e:
                logger.error(f'Error processing blob {blob.name}: {e}')
                error_count += 1
        
        logger.info(f'Archive sync complete. Archived: {archived_count}, Errors: {error_count}')
        return error_count == 0
        
    except Exception as e:
        logger.error(f'Archive sync failed: {e}')
        return False


if __name__ == '__main__':
    success = run_sync()
    sys.exit(0 if success else 1)
