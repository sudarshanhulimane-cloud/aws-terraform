# AWS Infrastructure Terraform Modules

This repository contains a comprehensive, modular Terraform configuration for deploying a complete AWS infrastructure stack. The configuration is designed to be reusable, scalable, and follows Terraform best practices.

## 🏗️ Architecture Overview

The infrastructure includes the following components:

### 1. **Networking** (`modules/networking`)
- VPC with configurable CIDR block
- 2 public subnets and 2 private subnets across 2 availability zones
- Internet Gateway for public internet access
- NAT Gateway for private subnet internet access
- Route Tables with appropriate routing rules
- Optional VPC Flow Logs

### 2. **Security** (`modules/security`)
- Security Groups for:
  - **Bastion Host**: SSH access from configurable CIDR blocks
  - **Application Load Balancer**: HTTP/HTTPS from anywhere
  - **Application Servers**: Internal communication and SSH from bastion
  - **EKS Cluster & Nodes**: Kubernetes communication
  - **RDS Database**: Database access from application tiers
- Configurable ports, protocols, and source IPs

### 3. **Compute** (`modules/compute`)
- **Bastion Host**: Secure SSH access point in public subnet
- **Auto Scaling Group**: Optional scalable application servers
- Launch Templates with user data scripts
- CloudWatch alarms for auto scaling
- Support for custom AMIs and instance types

### 4. **Load Balancing** (`modules/load_balancer`)
- Application Load Balancer in public subnets
- Target Groups with health checks
- HTTP and HTTPS listeners
- SSL/TLS termination support
- Custom listener rules support
- Optional WAF integration

### 5. **Container Orchestration** (`modules/eks`)
- Amazon EKS Cluster with configurable Kubernetes version
- Managed Node Groups with auto scaling
- Cluster logging enabled
- Security group integration
- IAM roles with least privilege access

### 6. **Storage** (`modules/storage`)
- S3 bucket with:
  - Versioning support
  - Server-side encryption (AES-256)
  - Public access blocked
  - Lifecycle policies
- Optional EBS volumes with encryption

### 7. **Database** (`modules/database`)
- RDS instance (PostgreSQL or MySQL)
- Database subnet group in private subnets
- Parameter groups for performance tuning
- Option groups (MySQL only)
- Automated backups and maintenance windows
- Optional read replicas
- Enhanced monitoring and Performance Insights
- Secrets Manager integration for password management

### 8. **DNS & Routing** (`modules/dns`)
- Route 53 hosted zone
- A records for ALB and bastion host
- Health checks for high availability

### 9. **Monitoring** (`modules/monitoring`)
- CloudWatch Log Groups for all services
- CloudWatch Alarms for:
  - CPU utilization (EC2, RDS)
  - ALB response times
  - Custom metrics
- Configurable retention periods

### 10. **IAM** (`modules/iam`)
- IAM roles and policies for:
  - EC2 instances (SSM, CloudWatch, S3 access)
  - EKS cluster and worker nodes
  - RDS enhanced monitoring
  - AWS Load Balancer Controller
  - Cluster Autoscaler
- Least privilege access principles

## 📁 Project Structure

```
.
├── main.tf                                    # Root module orchestration
├── variables.tf                               # Root module variables
├── outputs.tf                                 # Root module outputs
├── terraform.tf                               # Provider and backend configuration
├── README.md                                  # This file
│
├── modules/
│   ├── networking/
│   │   ├── main.tf                           # VPC, subnets, gateways, routing
│   │   ├── variables.tf                      # Network configuration variables
│   │   └── outputs.tf                        # VPC and subnet outputs
│   │
│   ├── security/
│   │   ├── main.tf                           # Security groups and rules
│   │   ├── variables.tf                      # Security configuration variables
│   │   └── outputs.tf                        # Security group outputs
│   │
│   ├── iam/
│   │   ├── main.tf                           # IAM roles, policies, instance profiles
│   │   ├── variables.tf                      # IAM configuration variables
│   │   └── outputs.tf                        # IAM resource outputs
│   │
│   ├── compute/
│   │   ├── main.tf                           # EC2 instances, ASG, launch templates
│   │   ├── variables.tf                      # Compute configuration variables
│   │   ├── outputs.tf                        # Instance and ASG outputs
│   │   └── user_data/
│   │       ├── bastion_user_data.sh          # Bastion host initialization script
│   │       └── app_server_user_data.sh       # Application server setup script
│   │
│   ├── load_balancer/
│   │   ├── main.tf                           # ALB, target groups, listeners
│   │   ├── variables.tf                      # Load balancer configuration
│   │   └── outputs.tf                        # ALB and target group outputs
│   │
│   ├── eks/
│   │   ├── main.tf                           # EKS cluster and node groups
│   │   ├── variables.tf                      # EKS configuration variables
│   │   └── outputs.tf                        # EKS cluster outputs
│   │
│   ├── storage/
│   │   ├── main.tf                           # S3 bucket and EBS volumes
│   │   ├── variables.tf                      # Storage configuration variables
│   │   └── outputs.tf                        # Storage resource outputs
│   │
│   ├── database/
│   │   ├── main.tf                           # RDS instance, subnet group, parameters
│   │   ├── variables.tf                      # Database configuration variables
│   │   └── outputs.tf                        # Database outputs
│   │
│   ├── dns/
│   │   ├── main.tf                           # Route 53 hosted zone and records
│   │   ├── variables.tf                      # DNS configuration variables
│   │   └── outputs.tf                        # DNS outputs
│   │
│   └── monitoring/
│       ├── main.tf                           # CloudWatch logs and alarms
│       ├── variables.tf                      # Monitoring configuration variables
│       └── outputs.tf                        # Monitoring outputs
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **AWS Account** with appropriate permissions
4. **EC2 Key Pair** created for SSH access (optional)

### Deployment Steps

1. **Clone and Navigate**
   ```bash
   git clone <repository-url>
   cd aws-terraform-infrastructure
   ```

2. **Configure Variables**
   Create a `terraform.tfvars` file:
   ```hcl
   # Basic Configuration
   project_name = "my-project"
   environment  = "dev"
   aws_region   = "us-west-2"
   
   # Networking
   vpc_cidr = "10.0.0.0/16"
   availability_zones = ["us-west-2a", "us-west-2b"]
   
   # Security
   bastion_allowed_cidrs = ["YOUR_IP/32"]
   ssh_key_name = "your-key-pair-name"
   
   # Optional: Enable features
   enable_auto_scaling = true
   create_route53_zone = true
   domain_name = "your-domain.com"
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan Deployment**
   ```bash
   terraform plan
   ```

5. **Deploy Infrastructure**
   ```bash
   terraform apply
   ```

6. **Access Resources**
   - Bastion Host: Use the public IP from outputs
   - Application Load Balancer: Use the DNS name from outputs
   - RDS Password: Stored in AWS Secrets Manager

## 🔧 Configuration Options

### Key Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_name` | Name of the project | `aws-infrastructure` | No |
| `environment` | Environment (dev/staging/prod) | `dev` | No |
| `aws_region` | AWS region for deployment | `us-west-2` | No |
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` | No |
| `ssh_key_name` | EC2 Key Pair for SSH access | `""` | Yes (for SSH) |
| `bastion_allowed_cidrs` | CIDRs allowed to SSH to bastion | `["0.0.0.0/0"]` | No |
| `enable_auto_scaling` | Enable Auto Scaling Group | `false` | No |
| `rds_engine` | Database engine (postgres/mysql) | `postgres` | No |
| `create_route53_zone` | Create Route 53 hosted zone | `false` | No |

### Advanced Configuration

#### Database Engine Selection
```hcl
# PostgreSQL (default)
rds_engine = "postgres"
rds_engine_version = "15.4"

# MySQL
rds_engine = "mysql"
rds_engine_version = "8.0"
```

#### Auto Scaling Configuration
```hcl
enable_auto_scaling = true
asg_min_size = 1
asg_max_size = 5
asg_desired_capacity = 2
```

#### EKS Configuration
```hcl
eks_cluster_version = "1.28"
eks_node_instance_types = ["t3.medium", "t3.large"]
eks_node_group_min_size = 1
eks_node_group_max_size = 5
```

## 🔒 Security Best Practices

This configuration implements several security best practices:

1. **Network Segmentation**: Public and private subnets with proper routing
2. **Least Privilege Access**: IAM roles with minimal required permissions
3. **Encryption**: 
   - EBS volumes encrypted by default
   - S3 bucket with server-side encryption
   - RDS encryption enabled
4. **Secret Management**: Database passwords stored in AWS Secrets Manager
5. **Security Groups**: Restrictive rules with minimal required access
6. **Bastion Host**: Secure access point for private resources
7. **VPC Flow Logs**: Optional network traffic monitoring

## 📊 Monitoring and Observability

### CloudWatch Integration

- **Log Groups**: Centralized logging for all services
- **Metrics**: Custom metrics for application performance
- **Alarms**: Automated alerting for system health
- **Dashboards**: Visual monitoring (can be added)

### Available Metrics

- EC2 CPU utilization
- RDS performance metrics
- ALB response times
- EKS cluster health
- Auto Scaling Group metrics

## 🛠️ Customization

### Adding New Services

1. Create a new module directory under `modules/`
2. Define `main.tf`, `variables.tf`, and `outputs.tf`
3. Add module call in root `main.tf`
4. Update root `variables.tf` and `outputs.tf`

### Modifying Existing Modules

Each module is self-contained and can be modified independently:
- Update variables for new configuration options
- Add resources for additional features
- Modify outputs for new data requirements

## 🔄 Lifecycle Management

### Updates and Maintenance

```bash
# Update Terraform modules
terraform plan
terraform apply

# Refresh state
terraform refresh

# Check for drift
terraform plan -detailed-exitcode
```

### Backup and Recovery

- **State Files**: Use remote state backend (S3 + DynamoDB)
- **Database**: Automated backups with point-in-time recovery
- **Infrastructure**: Version controlled Terraform code

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources. Ensure you have backups of important data.

## 📝 Notes

- RDS deletion protection is enabled by default
- S3 bucket versioning is enabled by default
- All resources are tagged consistently for cost tracking
- EKS cluster logs are enabled for all log types
- Enhanced monitoring available for RDS

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the Terraform documentation
2. Review AWS service documentation
3. Create an issue in this repository
4. Check existing issues for solutions

---

**Happy Terraforming! 🌍**