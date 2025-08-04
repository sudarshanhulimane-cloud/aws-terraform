# CloudFront Cache Invalidator Lambda Function

This Terraform configuration sets up a Lambda function that automatically invalidates CloudFront cache when new objects are uploaded to an S3 bucket.

## Features

- **Automatic Cache Invalidation**: Triggers CloudFront invalidation on S3 object creation
- **Flexible Runtime**: Supports both Node.js and Python Lambda runtimes
- **Secure IAM**: Minimal required permissions for CloudFront invalidation and CloudWatch logging
- **Existing Resource Integration**: References existing S3 bucket and CloudFront distribution

## Prerequisites

- Terraform installed (version >= 1.0)
- AWS CLI configured with appropriate permissions
- Existing S3 bucket
- Existing CloudFront distribution

## Required Permissions

The AWS credentials used must have permissions to:
- Create Lambda functions
- Create IAM roles and policies
- Create CloudWatch log groups
- Create S3 bucket notifications
- Read existing S3 bucket and CloudFront distribution

## Configuration

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Update the variables in `terraform.tfvars`:**
   ```hcl
   bucket_name = "your-existing-s3-bucket-name"
   cloudfront_distribution_id = "E1234567890ABCD"
   lambda_runtime = "nodejs18.x"  # or "python3.9"
   lambda_function_name = "cloudfront-cache-invalidator"
   ```

## Building the Lambda Function

### For Node.js (default):
```bash
./build_lambda.sh
```

### For Python:
```bash
./build_lambda.sh python
```

This will create a `lambda_function.zip` file in the root directory.

## Deployment

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Plan the deployment:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Architecture

The Terraform configuration creates:

1. **Data Sources:**
   - References existing S3 bucket
   - References existing CloudFront distribution

2. **IAM Resources:**
   - Lambda execution role
   - Policy for CloudFront invalidation and CloudWatch logging

3. **Lambda Function:**
   - Function with environment variable for CloudFront distribution ID
   - CloudWatch log group for monitoring

4. **S3 Integration:**
   - Lambda permission for S3 to invoke the function
   - S3 bucket notification for object creation events

## Lambda Function Behavior

When a new object is uploaded to the S3 bucket:

1. S3 triggers the Lambda function via event notification
2. Lambda extracts the object key from the S3 event
3. Lambda creates a CloudFront invalidation for the specific object path
4. CloudFront begins the invalidation process

## Monitoring

- **CloudWatch Logs**: All Lambda execution logs are available in CloudWatch
- **CloudFront Console**: Monitor invalidation status in the CloudFront console
- **Lambda Console**: Monitor function metrics and errors

## Outputs

After successful deployment, Terraform will output:
- `lambda_function_name`: Name of the created Lambda function
- `lambda_function_arn`: ARN of the Lambda function
- `lambda_role_arn`: ARN of the Lambda IAM role
- `cloudwatch_log_group_name`: Name of the CloudWatch log group

## Cleanup

To remove all created resources:
```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Lambda function not triggered:**
   - Verify S3 bucket notification is configured
   - Check Lambda permission allows S3 invocation
   - Ensure bucket name and distribution ID are correct

2. **CloudFront invalidation fails:**
   - Verify IAM policy includes `cloudfront:CreateInvalidation`
   - Check CloudFront distribution ID is correct
   - Ensure distribution is not disabled

3. **Build errors:**
   - Ensure Node.js/npm or Python/pip is installed
   - Check internet connectivity for package downloads

### Logs

Check CloudWatch logs for the Lambda function to debug issues:
```bash
aws logs tail /aws/lambda/cloudfront-cache-invalidator --follow
```

## Security Considerations

- The Lambda function has minimal required permissions
- IAM role follows the principle of least privilege
- CloudWatch logs are retained for 14 days by default
- All AWS API calls are logged for audit purposes

## Cost Considerations

- Lambda function: Pay per invocation and execution time
- CloudFront invalidations: First 1,000 paths per month are free
- CloudWatch logs: Pay for log storage and ingestion
- S3 notifications: No additional cost

## Support

For issues or questions, check the CloudWatch logs and ensure all prerequisites are met.