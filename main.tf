# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data blocks to reference existing resources
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_name
}

data "aws_cloudfront_distribution" "existing_distribution" {
  id = var.cloudfront_distribution_id
}

# Create a ZIP file for the Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.lambda_function_name}-role"
  }
}

# IAM policy for CloudFront invalidation
resource "aws_iam_policy" "cloudfront_invalidation_policy" {
  name        = "${var.lambda_function_name}-cloudfront-policy"
  description = "Policy to allow CloudFront cache invalidation"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = data.aws_cloudfront_distribution.existing_distribution.arn
      }
    ]
  })
}

# IAM policy for CloudWatch logging
resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "${var.lambda_function_name}-logging-policy"
  description = "Policy for Lambda CloudWatch logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      }
    ]
  })
}

# Attach CloudFront invalidation policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_cloudfront_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cloudfront_invalidation_policy.arn
}

# Attach CloudWatch logging policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14

  tags = {
    Name = "${var.lambda_function_name}-logs"
  }
}

# Lambda function
resource "aws_lambda_function" "cloudfront_invalidator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 60

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      CLOUDFRONT_DISTRIBUTION_ID = var.cloudfront_distribution_id
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_cloudfront_policy_attachment,
    aws_iam_role_policy_attachment.lambda_logging_policy_attachment,
    aws_cloudwatch_log_group.lambda_log_group,
  ]

  tags = {
    Name = var.lambda_function_name
  }
}

# Lambda permission to allow S3 to invoke the function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudfront_invalidator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.existing_bucket.arn
}

# S3 bucket notification to trigger Lambda on object creation
resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = data.aws_s3_bucket.existing_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cloudfront_invalidator.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}