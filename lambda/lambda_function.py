import json
import os
import boto3
import logging
from datetime import datetime
import uuid

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize CloudFront client
cloudfront = boto3.client('cloudfront')

def handler(event, context):
    """
    Lambda function to invalidate CloudFront cache when S3 objects are created
    """
    logger.info(f"Event received: {json.dumps(event)}")
    
    distribution_id = os.environ.get('CLOUDFRONT_DISTRIBUTION_ID')
    
    if not distribution_id:
        raise ValueError('CLOUDFRONT_DISTRIBUTION_ID environment variable is not set')
    
    try:
        # Extract the object key from the S3 event
        s3_record = event['Records'][0]['s3']
        object_key = s3_record['object']['key']
        
        # URL decode the object key
        import urllib.parse
        object_key = urllib.parse.unquote_plus(object_key)
        
        logger.info(f"Processing object: {object_key}")
        
        # Generate unique caller reference
        caller_reference = f"invalidation-{int(datetime.now().timestamp())}-{str(uuid.uuid4())[:8]}"
        
        # Create invalidation parameters
        invalidation_params = {
            'DistributionId': distribution_id,
            'InvalidationBatch': {
                'CallerReference': caller_reference,
                'Paths': {
                    'Quantity': 1,
                    'Items': [
                        f'/{object_key}'
                    ]
                }
            }
        }
        
        logger.info(f"Creating CloudFront invalidation with params: {json.dumps(invalidation_params)}")
        
        # Create the invalidation
        response = cloudfront.create_invalidation(**invalidation_params)
        
        logger.info(f"Invalidation created successfully: {json.dumps(response, default=str)}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'CloudFront invalidation created successfully',
                'invalidationId': response['Invalidation']['Id'],
                'objectKey': object_key
            })
        }
        
    except Exception as error:
        logger.error(f"Error creating CloudFront invalidation: {error}")
        raise error