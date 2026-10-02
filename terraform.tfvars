# Production-Ready EKS Terraform Configuration Variables
# Generated for optimal production deployment

# ============================================
# AWS Configuration
# ============================================
aws_region = "us-east-1"

# ============================================
# EKS Cluster Configuration
# ============================================
cluster_name    = "production-eks"
cluster_version = "1.29"
environment     = "production"

# ============================================
# VPC Configuration
# ============================================
# Main VPC CIDR block - allows 251 usable IPs per subnet
vpc_cidr = "10.0.0.0/16"

# Private subnets for worker nodes (3 across different AZs)
# These are isolated from the internet and must go through NAT Gateway
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

# Public subnets for load balancers and NAT Gateways (3 across different AZs)
# These have direct access to the internet via Internet Gateway
public_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# ============================================
# Network Configuration
# ============================================
# Enable NAT Gateways for private subnet internet access
enable_nat_gateway = true

# Set to true for cost savings in dev/test environments (single NAT Gateway)
# Set to false for production (one NAT Gateway per AZ for redundancy)
single_nat_gateway = false

# Enable DNS features for proper Kubernetes networking
enable_dns_hostnames = true
enable_dns_support   = true

# ============================================
# EKS Node Group Configuration
# ============================================
node_group_name = "production-node-group"

# Scaling configuration
# Desired: target number of nodes to run
# Min: minimum during scale-down
# Max: maximum during scale-up (controlled by cluster autoscaler)
node_desired_size = 3
node_min_size     = 2
node_max_size     = 6

# Instance types for worker nodes
# Production recommendation: t3.large or larger
# For cost-effective dev/test: t3.medium
# Multiple types can be specified for Spot instance diversity
node_instance_types = ["t3.medium"]

# EBS volume size for worker nodes (in GiB)
# Production minimum: 50 GiB
# Adjust based on workload requirements
node_disk_size = 50

# ============================================
# Features & Monitoring
# ============================================
enable_cluster_autoscaling = true
enable_monitoring          = true

# ============================================
# Resource Tags
# ============================================
# Tags are applied to all resources for cost tracking, automation, and management
tags = {
  Environment = "production"
  ManagedBy   = "Terraform"
  Project     = "EKS-Infrastructure"
  Owner       = "DevOps"
  CostCenter  = "Engineering"
  CreatedAt   = "2026-10-02"
}

# ============================================
# Deployment Notes
# ============================================
# 
# Before running 'terraform apply':
# 
# 1. Update AWS Region:
#    - Change aws_region to your desired region (e.g., "us-west-2", "eu-west-1")
#
# 2. Customize Cluster Name:
#    - Update cluster_name to match your naming convention
#
# 3. Configure Node Scaling:
#    - Adjust node_desired_size, node_min_size, node_max_size based on workload
#    - Typical production: desired=3, min=2, max=6
#    - Dev/test: desired=1, min=1, max=3
#
# 4. Choose Instance Types:
#    - Production: t3.large, t3.xlarge, or m5.large
#    - Dev/test: t3.medium (cost-effective)
#    - Memory-intensive: r5 series
#    - Compute-intensive: c5 series
#
# 5. Network Configuration:
#    - For production: single_nat_gateway = false (one per AZ)
#    - For dev/test: single_nat_gateway = true (cost-saving)
#
# 6. Update Tags:
#    - Add your company-specific tags for billing and governance
#
# 7. Enable Monitoring:
#    - Keep enable_monitoring = true for production
#    - CloudWatch logs are essential for troubleshooting
#
# Estimated Costs (us-east-1):
# - EKS Cluster: $0.10/hour (~$73/month)
# - 3x t3.medium nodes: ~$0.0416 * 3 * 730 hours = ~$91/month
# - NAT Gateway (1): $32/month + data transfer costs
# - Total estimated: ~$196-250/month
#
# Deploy Command:
#   $ terraform init
#   $ terraform plan -out=tfplan
#   $ terraform apply tfplan
#
# Estimated deployment time: 15-20 minutes
#
# Post-deployment:
#   $ aws eks update-kubeconfig --region us-east-1 --name production-eks
#   $ kubectl get nodes
#
