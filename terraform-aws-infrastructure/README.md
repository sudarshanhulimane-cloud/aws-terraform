# Terraform AWS Infrastructure

A comprehensive, modular Terraform configuration for AWS infrastructure deployment.

## Overview

This Terraform project provides a complete AWS infrastructure setup with the following components:

### 1. **Networking**
- VPC with configurable CIDR
- 2 public subnets and 2 private subnets across 2 AZs
- Internet Gateway
- NAT Gateway
- Route Tables for public and private subnets

### 2. **Security**
- Security groups for:
  - Bastion Host (SSH from configurable CIDR)
  - ALB (HTTP/HTTPS from 0.0.0.0/0)
  - EKS Worker Nodes (internal)
  - RDS (restricted inbound)
- Configurable ports, protocols, and source IPs

### 3. **Compute**
- Bastion Host in public subnet
- Auto Scaling Group for application servers
- EC2 Instance Module

### 4. **Load Balancing**
- Application Load Balancer in public subnets
- Target Groups and Listener rules
- SSL/TLS support

### 5. **Containers**
- Amazon EKS Cluster
- EKS Node Groups (managed)
- IAM roles for EKS control plane and workers

### 6. **Storage**
- S3 bucket with versioning and encryption
- Lifecycle policies for cost optimization

### 7. **Database**
- RDS (PostgreSQL/MySQL) in private subnets
- Parameter groups and subnet groups
- Multi-AZ setup optional

### 8. **DNS & Routing**
- Route 53 hosted zone
- A records for ALB, Bastion
- CNAME records for API and Admin

### 9. **Monitoring**
- CloudWatch Log Groups
- CloudWatch Alarms (CPU, Memory, Disk for EC2/EKS)

### 10. **IAM**
- IAM roles and policies for:
  - EC2 instances
  - EKS
  - S3 access

## Project Structure

```
terraform-aws-infrastructure/
├── main.tf                 # Root configuration
├── variables.tf            # Root variables
├── outputs.tf              # Root outputs
├── README.md               # This file
├── environments/           # Environment-specific configurations
│   ├── dev/
│   └── prod/
└── modules/                # Reusable modules
    ├── networking/         # VPC, Subnets, IGW, NAT
    ├── security/           # Security Groups
    ├── iam/               # IAM Roles and Policies
    ├── storage/           # S3 Bucket
    ├── database/          # RDS
    ├── load-balancing/    # ALB, Target Groups
    ├── compute/           # EC2, Auto Scaling
    ├── containers/        # EKS Cluster and Node Groups
    ├── dns/              # Route 53
    └── monitoring/       # CloudWatch
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- Appropriate AWS permissions

## Usage

### 1. Initialize Terraform

```bash
cd terraform-aws-infrastructure
terraform init
```

### 2. Plan the Deployment

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

### 4. Destroy Infrastructure (if needed)

```bash
terraform destroy
```

## Configuration

### Environment Variables

Set the following environment variables or create a `terraform.tfvars` file:

```hcl
aws_region = "us-west-2"
environment = "dev"
project_name = "my-project"
vpc_cidr = "10.0.0.0/16"
```

### Key Variables

- `aws_region`: AWS region for deployment
- `environment`: Environment name (dev, staging, prod)
- `project_name`: Project name for resource naming
- `vpc_cidr`: CIDR block for VPC
- `bastion_allowed_cidrs`: CIDR blocks allowed to access bastion
- `db_password`: Database password (sensitive)

## Security Considerations

1. **Bastion Host**: Restrict access to your IP range
2. **Database**: Use strong passwords and enable encryption
3. **S3**: Enable versioning and encryption
4. **EKS**: Use private subnets and restrict access
5. **ALB**: Enable deletion protection in production

## Cost Optimization

1. **RDS**: Use appropriate instance types
2. **EKS**: Right-size node groups
3. **S3**: Configure lifecycle policies
4. **EC2**: Use Spot instances where appropriate
5. **NAT Gateway**: Consider NAT instances for dev environments

## Monitoring

The infrastructure includes comprehensive monitoring:

- CloudWatch Logs for all services
- CPU, Memory, and Disk alarms
- RDS connection monitoring
- ALB error rate monitoring

## Troubleshooting

### Common Issues

1. **VPC CIDR conflicts**: Ensure VPC CIDR doesn't overlap with existing VPCs
2. **Subnet CIDR conflicts**: Ensure subnet CIDRs are within VPC CIDR
3. **IAM permissions**: Ensure AWS credentials have sufficient permissions
4. **EKS version compatibility**: Check EKS and node group version compatibility

### Useful Commands

```bash
# Check Terraform state
terraform state list

# Import existing resources
terraform import module.networking.aws_vpc.main vpc-12345678

# Validate configuration
terraform validate

# Format code
terraform fmt
```

## Contributing

1. Follow Terraform best practices
2. Use consistent naming conventions
3. Add appropriate tags to all resources
4. Document any changes in README
5. Test in dev environment before production

## License

This project is licensed under the MIT License.