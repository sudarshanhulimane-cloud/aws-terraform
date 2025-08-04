import json
import os
import boto3
import logging
from datetime import datetime
import uuid

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
cloudfront = boto3.client('cloudfront')
s3 = boto3.client('s3')

def lambda_handler(event, context):
    """
    Lambda function to invalidate CloudFront cache when S3 objects are created
    """
    logger.info(f"Event received: {json.dumps(event)}")
    
    distribution_id = os.environ.get('CLOUDFRONT_DISTRIBUTION_ID')
    
    if not distribution_id:
        raise ValueError('CLOUDFRONT_DISTRIBUTION_ID environment variable is not set')
    
    try:
        results = []
        
        # Process each S3 event record
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            
            # URL decode the object key
            import urllib.parse
            object_key = urllib.parse.unquote_plus(object_key)
            
            logger.info(f"Processing S3 event for bucket: {bucket_name}, key: {object_key}")
            
            # Create CloudFront invalidation
            caller_reference = f"s3-{int(datetime.now().timestamp())}-{str(uuid.uuid4())[:8]}"
            
            invalidation_params = {
                'DistributionId': distribution_id,
                'InvalidationBatch': {
                    'CallerReference': caller_reference,
                    'Paths': {
                        'Quantity': 1,
                        'Items': [f'/{object_key}']
                    }
                }
            }
            
            logger.info(f"Creating CloudFront invalidation with params: {json.dumps(invalidation_params)}")
            
            response = cloudfront.create_invalidation(**invalidation_params)
            
            logger.info(f"CloudFront invalidation created successfully: {json.dumps(response)}")
            
            results.append({
                'bucket_name': bucket_name,
                'object_key': object_key,
                'invalidation_id': response['Invalidation']['Id'],
                'status': 'success'
            })
        
        logger.info(f"All invalidations processed successfully: {json.dumps(results)}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'CloudFront invalidations created successfully',
                'results': results
            })
        }
        
    except Exception as error:
        logger.error(f"Error creating CloudFront invalidation: {str(error)}")
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error creating CloudFront invalidation',
                'error': str(error)
            })
        }