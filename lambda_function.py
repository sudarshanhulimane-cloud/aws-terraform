import json
import boto3
import os
from urllib.parse import unquote_plus

def lambda_handler(event, context):
    """
    Lambda function to invalidate CloudFront cache when S3 objects are created/updated.
    """
    
    # Initialize CloudFront client
    cloudfront = boto3.client('cloudfront')
    
    # Get CloudFront distribution ID from environment variable
    distribution_id = os.environ['CLOUDFRONT_DISTRIBUTION_ID']
    
    # List to store paths to invalidate
    paths_to_invalidate = []
    
    # Process S3 event records
    for record in event['Records']:
        # Get bucket name and object key from the event
        bucket_name = record['s3']['bucket']['name']
        object_key = unquote_plus(record['s3']['object']['key'])
        
        # Create the path for CloudFront invalidation (must start with /)
        path = f"/{object_key}"
        paths_to_invalidate.append(path)
        
        print(f"Processing S3 event: bucket={bucket_name}, key={object_key}")
    
    # Remove duplicates
    paths_to_invalidate = list(set(paths_to_invalidate))
    
    if paths_to_invalidate:
        try:
            # Create invalidation request
            response = cloudfront.create_invalidation(
                DistributionId=distribution_id,
                InvalidationBatch={
                    'Paths': {
                        'Quantity': len(paths_to_invalidate),
                        'Items': paths_to_invalidate
                    },
                    'CallerReference': context.aws_request_id
                }
            )
            
            invalidation_id = response['Invalidation']['Id']
            
            print(f"Successfully created CloudFront invalidation {invalidation_id} for distribution {distribution_id}")
            print(f"Invalidated paths: {paths_to_invalidate}")
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'CloudFront invalidation created successfully',
                    'invalidation_id': invalidation_id,
                    'distribution_id': distribution_id,
                    'paths': paths_to_invalidate
                })
            }
            
        except Exception as e:
            print(f"Error creating CloudFront invalidation: {str(e)}")
            raise e
    else:
        print("No paths to invalidate")
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'No paths to invalidate'
            })
        }