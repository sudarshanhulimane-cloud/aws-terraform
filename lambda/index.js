const AWS = require('aws-sdk');

// Initialize AWS SDK
const cloudfront = new AWS.CloudFront();
const s3 = new AWS.S3();

exports.handler = async (event) => {
    console.log('Event received:', JSON.stringify(event, null, 2));
    
    const distributionId = process.env.CLOUDFRONT_DISTRIBUTION_ID;
    
    if (!distributionId) {
        throw new Error('CLOUDFRONT_DISTRIBUTION_ID environment variable is not set');
    }
    
    try {
        // Process each S3 event record
        const invalidationPromises = event.Records.map(async (record) => {
            const bucketName = record.s3.bucket.name;
            const objectKey = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
            
            console.log(`Processing S3 event for bucket: ${bucketName}, key: ${objectKey}`);
            
            // Create CloudFront invalidation
            const invalidationParams = {
                DistributionId: distributionId,
                InvalidationBatch: {
                    CallerReference: `s3-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
                    Paths: {
                        Quantity: 1,
                        Items: [`/${objectKey}`]
                    }
                }
            };
            
            console.log('Creating CloudFront invalidation with params:', JSON.stringify(invalidationParams, null, 2));
            
            const result = await cloudfront.createInvalidation(invalidationParams).promise();
            
            console.log('CloudFront invalidation created successfully:', JSON.stringify(result, null, 2));
            
            return {
                bucketName,
                objectKey,
                invalidationId: result.Invalidation.Id,
                status: 'success'
            };
        });
        
        const results = await Promise.all(invalidationPromises);
        
        console.log('All invalidations processed successfully:', JSON.stringify(results, null, 2));
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'CloudFront invalidations created successfully',
                results: results
            })
        };
        
    } catch (error) {
        console.error('Error creating CloudFront invalidation:', error);
        
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error creating CloudFront invalidation',
                error: error.message
            })
        };
    }
};