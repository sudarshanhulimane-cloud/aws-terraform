#!/bin/bash

# Terraform AWS Infrastructure Deployment Script
# Usage: ./deploy.sh [environment] [action]
# Example: ./deploy.sh dev plan

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|prod)$ ]]; then
    echo -e "${RED}Error: Environment must be 'dev' or 'prod'${NC}"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(init|plan|apply|destroy|output)$ ]]; then
    echo -e "${RED}Error: Action must be 'init', 'plan', 'apply', 'destroy', or 'output'${NC}"
    exit 1
fi

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# Set up environment-specific variables
ENV_FILE="environments/${ENVIRONMENT}/terraform.tfvars"

if [[ ! -f "$ENV_FILE" ]]; then
    print_error "Environment file not found: $ENV_FILE"
    exit 1
fi

print_status "Deploying to environment: $ENVIRONMENT"
print_status "Action: $ACTION"

# Create backend configuration if it doesn't exist
BACKEND_CONFIG="environments/${ENVIRONMENT}/backend.tf"

if [[ ! -f "$BACKEND_CONFIG" ]]; then
    print_warning "Backend configuration not found. Creating local backend..."
    cat > "$BACKEND_CONFIG" << EOF
terraform {
  backend "local" {
    path = "environments/${ENVIRONMENT}/terraform.tfstate"
  }
}
EOF
fi

# Change to the environment directory
cd "environments/${ENVIRONMENT}"

# Create symlink to root module files if they don't exist
if [[ ! -L "main.tf" ]]; then
    ln -sf ../../main.tf .
    ln -sf ../../variables.tf .
    ln -sf ../../outputs.tf .
fi

# Execute terraform command
case $ACTION in
    "init")
        print_status "Initializing Terraform..."
        terraform init
        ;;
    "plan")
        print_status "Planning Terraform deployment..."
        terraform plan -var-file="terraform.tfvars"
        ;;
    "apply")
        print_warning "This will create/modify AWS resources. Are you sure? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Applying Terraform configuration..."
            terraform apply -var-file="terraform.tfvars" -auto-approve
        else
            print_status "Deployment cancelled."
            exit 0
        fi
        ;;
    "destroy")
        print_warning "This will DESTROY all AWS resources. Are you sure? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_warning "This action cannot be undone. Are you absolutely sure? (y/N)"
            read -r response2
            if [[ "$response2" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                print_status "Destroying infrastructure..."
                terraform destroy -var-file="terraform.tfvars" -auto-approve
            else
                print_status "Destruction cancelled."
                exit 0
            fi
        else
            print_status "Destruction cancelled."
            exit 0
        fi
        ;;
    "output")
        print_status "Showing Terraform outputs..."
        terraform output
        ;;
esac

print_status "Deployment script completed successfully!"