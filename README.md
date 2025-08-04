# CloudFront Invalidation Lambda Function

This Terraform configuration sets up a Lambda function that automatically invalidates CloudFront cache when objects are created in an S3 bucket. The Lambda function is triggered by S3 event notifications and uses the CloudFront CreateInvalidation API to clear the cache for the specific object.

## Features

- **Automatic Cache Invalidation**: Triggers CloudFront invalidation when S3 objects are created
- **Flexible Filtering**: Optional prefix and suffix filters for S3 events
- **Comprehensive Logging**: CloudWatch logs for monitoring and debugging
- **Secure IAM**: Minimal required permissions for CloudFront and CloudWatch
- **Multiple Language Support**: Available in both Node.js and Python

## Prerequisites

- Terraform installed (version >= 1.0)
- AWS CLI configured with appropriate permissions
- Existing S3 bucket
- Existing CloudFront distribution
- Node.js or Python (for building the Lambda package)

## Required Permissions

The AWS credentials used must have permissions to:
- Create and manage Lambda functions
- Create and manage IAM roles and policies
- Create CloudWatch log groups
- Configure S3 bucket notifications
- Read existing S3 bucket and CloudFront distribution

## Quick Start

1. **Clone or download this repository**

2. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` with your actual values:
   ```hcl
   bucket_name = "your-actual-bucket-name"
   cloudfront_distribution_id = "E1234567890ABCD"
   ```

3. **Build the Lambda deployment package**:
   ```bash
   # For Node.js (default)
   ./build_lambda.sh nodejs
   
   # For Python
   ./build_lambda.sh python
   ```

4. **Deploy with Terraform**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

| Variable | Description | Type |
|----------|-------------|------|
| `bucket_name` | Name of the existing S3 bucket | string |
| `cloudfront_distribution_id` | ID of the existing CloudFront distribution | string |

### Optional Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `lambda_function_name` | Name of the Lambda function | string | `"cloudfront-invalidation-lambda"` |
| `s3_event_filter_prefix` | S3 event filter prefix | string | `""` |
| `s3_event_filter_suffix` | S3 event filter suffix | string | `""` |
| `lambda_timeout` | Lambda function timeout in seconds | number | `30` |
| `lambda_memory_size` | Lambda function memory size in MB | number | `128` |
| `log_retention_days` | CloudWatch log retention in days | number | `14` |

## Architecture

```
S3 Bucket → Event Notification → Lambda Function → CloudFront Invalidation
```

1. **S3 Event**: When an object is created in the S3 bucket, it triggers an event notification
2. **Lambda Trigger**: The event notification invokes the Lambda function
3. **Cache Invalidation**: The Lambda function creates a CloudFront invalidation for the specific object
4. **Logging**: All operations are logged to CloudWatch for monitoring

## IAM Permissions

The Lambda function's execution role includes the following permissions:

- `cloudfront:CreateInvalidation` - To create CloudFront invalidations
- `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents` - For CloudWatch logging

## Monitoring

### CloudWatch Logs

The Lambda function logs to CloudWatch with the following information:
- S3 event details
- CloudFront invalidation parameters
- Success/failure status
- Error messages (if any)

### Log Group

The log group is created at: `/aws/lambda/{lambda_function_name}`

## Testing

To test the setup:

1. Upload a file to your S3 bucket
2. Check the CloudWatch logs for the Lambda function
3. Verify that a CloudFront invalidation was created in the AWS Console

## Troubleshooting

### Common Issues

1. **Lambda function not triggered**:
   - Check S3 bucket notification configuration
   - Verify Lambda permission allows S3 invocation
   - Check CloudWatch logs for errors

2. **CloudFront invalidation fails**:
   - Verify the CloudFront distribution ID is correct
   - Check IAM permissions for CloudFront
   - Ensure the distribution is not disabled

3. **Build errors**:
   - Ensure Node.js or Python is installed
   - Check that the build script has execute permissions
   - Verify all dependencies are available

### Debugging

Enable detailed logging by checking the CloudWatch logs:
```bash
aws logs tail /aws/lambda/{lambda_function_name} --follow
```

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Security Considerations

- The Lambda function has minimal required permissions
- CloudFront invalidations are scoped to specific objects
- All operations are logged for audit purposes
- Environment variables are used for configuration

## Cost Optimization

- CloudFront invalidations have associated costs
- Consider using invalidation batching for high-frequency updates
- Monitor Lambda execution time and memory usage
- Adjust log retention period based on your needs

## License

This project is licensed under the MIT License.