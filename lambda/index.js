const AWS = require('aws-sdk');

const cloudfront = new AWS.CloudFront();

exports.handler = async (event) => {
    console.log('Event received:', JSON.stringify(event, null, 2));
    
    const distributionId = process.env.CLOUDFRONT_DISTRIBUTION_ID;
    
    if (!distributionId) {
        throw new Error('CLOUDFRONT_DISTRIBUTION_ID environment variable is not set');
    }
    
    try {
        // Extract the object key from the S3 event
        const s3Record = event.Records[0].s3;
        const objectKey = decodeURIComponent(s3Record.object.key.replace(/\+/g, ' '));
        
        console.log(`Processing object: ${objectKey}`);
        
        // Create invalidation parameters
        const invalidationParams = {
            DistributionId: distributionId,
            InvalidationBatch: {
                CallerReference: `invalidation-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
                Paths: {
                    Quantity: 1,
                    Items: [
                        `/${objectKey}`
                    ]
                }
            }
        };
        
        console.log('Creating CloudFront invalidation with params:', JSON.stringify(invalidationParams, null, 2));
        
        // Create the invalidation
        const result = await cloudfront.createInvalidation(invalidationParams).promise();
        
        console.log('Invalidation created successfully:', JSON.stringify(result, null, 2));
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'CloudFront invalidation created successfully',
                invalidationId: result.Invalidation.Id,
                objectKey: objectKey
            })
        };
        
    } catch (error) {
        console.error('Error creating CloudFront invalidation:', error);
        throw error;
    }
};