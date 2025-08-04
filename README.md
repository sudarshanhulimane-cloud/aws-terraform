# CloudFront Cache Invalidation Lambda

This Terraform configuration sets up an AWS Lambda function that automatically invalidates CloudFront cache when objects are created or updated in an S3 bucket.

## Architecture

- **Lambda Function**: Python-based function that processes S3 events and creates CloudFront invalidations
- **S3 Event Notification**: Configured to trigger the Lambda function on `s3:ObjectCreated:*` events
- **IAM Roles & Policies**: Provides necessary permissions for CloudFront invalidation and CloudWatch logging
- **CloudWatch Logs**: Centralized logging for monitoring and debugging

## Prerequisites

1. **Existing S3 Bucket**: You must have an existing S3 bucket that you want to monitor
2. **Existing CloudFront Distribution**: You must have an existing CloudFront distribution that serves content from the S3 bucket
3. **AWS CLI Configured**: Ensure your AWS credentials are properly configured
4. **Terraform Installed**: Version 0.14 or later

## Files

- `main.tf` - Main Terraform configuration with all resources
- `variables.tf` - Input variables for the configuration
- `outputs.tf` - Outputs including Lambda function name and ARN
- `lambda_function.py` - Python Lambda function code
- `README.md` - This documentation

## Usage

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd cloudfront-cache-invalidation
```

### 2. Configure Variables

Create a `terraform.tfvars` file with your specific values:

```hcl
bucket_name                 = "my-existing-bucket"
cloudfront_distribution_id  = "E1234567890ABC"
aws_region                 = "us-east-1"
lambda_function_name       = "cloudfront-cache-invalidator"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan the Deployment

```bash
terraform plan
```

### 5. Apply the Configuration

```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### 6. Verify the Setup

After successful deployment, you can verify the setup by:

1. Uploading a file to your S3 bucket
2. Checking CloudWatch logs for the Lambda function
3. Verifying that a CloudFront invalidation was created

## Variables

| Variable | Description | Type | Required | Default |
|----------|-------------|------|----------|---------|
| `bucket_name` | Name of the existing S3 bucket | string | Yes | - |
| `cloudfront_distribution_id` | ID of the existing CloudFront distribution | string | Yes | - |
| `aws_region` | AWS region for resources | string | No | us-east-1 |
| `lambda_function_name` | Name of the Lambda function | string | No | cloudfront-cache-invalidator |

## Outputs

| Output | Description |
|--------|-------------|
| `lambda_function_name` | Name of the created Lambda function |
| `lambda_function_arn` | ARN of the Lambda function |
| `lambda_role_arn` | ARN of the Lambda IAM role |
| `cloudwatch_log_group_name` | Name of the CloudWatch log group |
| `s3_bucket_name` | Name of the configured S3 bucket |
| `cloudfront_distribution_id` | ID of the CloudFront distribution |

## Lambda Function Details

The Lambda function (`lambda_function.py`) performs the following actions:

1. **Processes S3 Events**: Extracts bucket name and object key from S3 event notifications
2. **Creates Invalidation Paths**: Converts S3 object keys to CloudFront paths (prefixed with `/`)
3. **Calls CloudFront API**: Uses the `CreateInvalidation` API to invalidate cached content
4. **Logs Results**: Provides detailed logging for monitoring and debugging

### Environment Variables

The Lambda function uses the following environment variable:
- `CLOUDFRONT_DISTRIBUTION_ID`: Set automatically by Terraform from the input variable

## IAM Permissions

The Lambda function is granted the following permissions:

### CloudFront Permissions
- `cloudfront:CreateInvalidation` on the specified CloudFront distribution

### CloudWatch Permissions
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`

## Monitoring

### CloudWatch Logs

The Lambda function logs are available in CloudWatch under the log group:
`/aws/lambda/{lambda_function_name}`

Log retention is set to 14 days by default.

### Monitoring Events

You can monitor the following in CloudWatch:
- Lambda function invocations
- Lambda function errors
- CloudFront invalidation requests
- S3 event processing

## Troubleshooting

### Common Issues

1. **Lambda Not Triggered**
   - Verify S3 bucket notification configuration
   - Check Lambda permissions for S3 invocation
   - Ensure the bucket name matches the variable

2. **CloudFront Invalidation Fails**
   - Verify CloudFront distribution ID is correct
   - Check IAM permissions for CloudFront invalidation
   - Ensure the distribution exists and is active

3. **Timeout Errors**
   - Lambda timeout is set to 60 seconds
   - Large numbers of files may require optimization

### Debugging

1. Check CloudWatch logs for detailed error messages
2. Test the Lambda function manually with a sample S3 event
3. Verify IAM role permissions in the AWS console

## Security Considerations

- The Lambda function only has minimum required permissions
- CloudFront invalidation is limited to the specified distribution
- CloudWatch logs are encrypted at rest
- S3 bucket permissions should be configured separately

## Cost Considerations

- **Lambda Invocations**: Charged per request and execution time
- **CloudFront Invalidations**: First 1,000 invalidation paths per month are free, additional paths cost $0.005 each
- **CloudWatch Logs**: Storage and ingestion costs apply

## Cleanup

To remove all resources created by this configuration:

```bash
terraform destroy
```

When prompted, type `yes` to confirm the destruction.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.