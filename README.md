# Production-Ready EKS Terraform Configuration

This repository contains a complete, production-ready Terraform configuration for deploying an Amazon EKS (Elastic Kubernetes Service) cluster with a custom VPC on AWS.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
- [Configuration](#configuration)
- [Cluster Access](#cluster-access)
- [Monitoring and Logging](#monitoring-and-logging)
- [Scaling](#scaling)
- [Maintenance](#maintenance)
- [Cleanup](#cleanup)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## Features

✅ **Production-Ready Configuration**
- Multi-AZ deployment for high availability
- Private subnets for worker nodes with NAT Gateway
- Public subnets for load balancers
- Security groups with least privilege access
- CloudWatch logging enabled by default

✅ **Best Practices**
- IRSA (IAM Roles for Service Accounts) support
- OIDC provider configured
- Proper IAM roles and policies
- Resource tagging for cost tracking and management
- State management ready (S3 backend configuration included)

✅ **Highly Customizable**
- All resources configurable via variables
- Multiple node group support
- Flexible networking (single or multiple NAT gateways)
- Cluster auto-scaling ready
- Monitoring and logging options

✅ **Security**
- Private worker nodes (not exposed to internet)
- Security groups with restricted access
- IAM least privilege principle
- IMDSv2 enforced on EC2 instances
- VPC endpoint support ready

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │   Public Subnet  │  │   Public Subnet  │                 │
│  │   (10.0.101.0)   │  │   (10.0.102.0)   │                 │
│  │                  │  │                  │                 │
│  │  IGW  ALB/NLB    │  │  IGW  ALB/NLB    │                 │
│  │   |       |      │  │   |       |      │                 │
│  │   └───────┘      │  │   └───────┘      │                 │
│  └────────┬─────────┘  └────────┬─────────┘                 │
│           │                     │                           │
│           │    NAT Gateway      │                           │
│           └──────────┬──────────┘                           │
│                      │                                      │
│  ┌──────────────────────────────────────────────┐          │
│  │          Private Subnets (Worker Nodes)      │          │
│  │                                              │          │
│  │  ┌─────────────┐  ┌──────────────────────┐  │          │
│  │  │  EKS Nodes  │  │  EKS Nodes           │  │          │
│  │  │  Pods       │  │  Pods                │  │          │
│  │  └─────────────┘  └──────────────────────┘  │          │
│  │                                              │          │
│  └──────────────────────────────────────────────┘          │
│                                                              │
│  EKS Control Plane (Managed by AWS)                        │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required Tools

1. **Terraform** (>= 1.0)
   ```bash
   # macOS
   brew install terraform
   
   # Windows (using Chocolatey)
   choco install terraform
   
   # Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y terraform
   ```

2. **AWS CLI** (>= 2.0)
   ```bash
   # Install AWS CLI v2
   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
   ```

3. **kubectl** (>= 1.27)
   ```bash
   # macOS
   brew install kubectl
   
   # Windows
   choco install kubernetes-cli
   
   # Ubuntu/Debian
   sudo apt-get install -y kubectl
   ```

### AWS Account Requirements

- Active AWS account with appropriate permissions
- User/Role with permissions to create:
  - VPC, Subnets, Internet Gateways, Route Tables, NAT Gateways
  - EKS Cluster and Node Groups
  - IAM Roles and Policies
  - Security Groups
  - CloudWatch Log Groups (optional)

### Permissions Policy Example

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "iam:*",
        "logs:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Quick Start

### Step 1: Clone the Repository

```bash
git clone https://github.com/mahiavi/TF-EKS.git
cd TF-EKS
```

### Step 2: Configure AWS Credentials

```bash
# Option 1: Using AWS CLI
aws configure

# Option 2: Using environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 3: Using IAM role (if on EC2)
# Attach IAM role to EC2 instance directly
```

### Step 3: Create Terraform Variables File

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your values
```

### Step 4: Initialize Terraform

```bash
terraform init
```

### Step 5: Plan the Deployment

```bash
terraform plan -out=tfplan
```

### Step 6: Apply the Configuration

```bash
terraform apply tfplan
```

**Estimated deployment time: 15-20 minutes**

## Step-by-Step Deployment Guide

### Step 1: Validate Prerequisites

```bash
# Check Terraform version
terraform version

# Check AWS CLI configuration
aws sts get-caller-identity

# Check kubectl version
kubectl version --client
```

### Step 2: Configure Your Environment

Create a `terraform.tfvars` file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your preferred values:

```hcl
aws_region     = "us-east-1"
cluster_name   = "my-production-eks"
cluster_version = "1.29"

# Network configuration
vpc_cidr = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# Node configuration
node_desired_size  = 3
node_min_size      = 2
node_max_size      = 6
node_instance_types = ["t3.medium"]

# Features
enable_nat_gateway = true
enable_monitoring  = true
enable_cluster_autoscaling = true

tags = {
  Environment = "production"
  ManagedBy   = "Terraform"
  Project     = "my-project"
}
```

### Step 3: Initialize Terraform Working Directory

```bash
terraform init
```

This command will:
- Download and install AWS provider
- Download and install TLS provider
- Initialize the `.terraform` directory

### Step 4: Validate Configuration

```bash
terraform validate
```

This checks:
- Terraform syntax
- Configuration validity
- Provider compatibility

### Step 5: Plan the Infrastructure

```bash
terraform plan -out=tfplan
```

Review the output carefully:
- ✓ Check number of resources to create
- ✓ Verify instance types and sizes
- ✓ Confirm subnet CIDR blocks
- ✓ Review security group rules

**Example output:**
```
Plan: 38 to add, 0 to change, 0 to destroy.
```

### Step 6: Deploy the Infrastructure

```bash
terraform apply tfplan
```

**During deployment:**
- Watch for any errors or warnings
- The process typically takes 15-20 minutes
- AWS creates EKS control plane and worker nodes
- CloudWatch log groups are created (if monitoring enabled)

**Sample output:**
```
Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

Outputs:

cluster_endpoint = "https://xxx.eks.us-east-1.amazonaws.com"
cluster_id = "my-production-eks"
...
```

### Step 7: Configure kubectl

After deployment completes, configure kubectl to access your cluster:

```bash
# Get the command from terraform outputs
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")
CLUSTER_NAME=$(terraform output -raw cluster_id)

aws eks update-kubeconfig \
  --region $AWS_REGION \
  --name $CLUSTER_NAME
```

Or use the terraform output directly:

```bash
terraform output configure_kubectl | bash
```

### Step 8: Verify Cluster Access

```bash
# Test cluster connection
kubectl cluster-info

# List nodes
kubectl get nodes

# List all pods (including system pods)
kubectl get pods -A
```

**Expected output:**
```
NAME                          STATUS   ROLES    AGE    VERSION
ip-10-0-1-xxx.ec2.internal   Ready    <none>   5m     v1.29.x
ip-10-0-2-xxx.ec2.internal   Ready    <none>   5m     v1.29.x
ip-10-0-3-xxx.ec2.internal   Ready    <none>   5m     v1.29.x
```

### Step 9: Deploy a Test Application (Optional)

```bash
# Create a test namespace
kubectl create namespace test

# Deploy nginx
kubectl create deployment nginx --image=nginx -n test
kubectl expose deployment nginx --port=80 --type=LoadBalancer -n test

# Wait for LoadBalancer IP
kubectl get svc -n test -w

# Clean up
kubectl delete namespace test
```

## Configuration

### Variable Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | us-east-1 | AWS region for deployment |
| `cluster_name` | string | production-eks | Name of the EKS cluster |
| `cluster_version` | string | 1.29 | Kubernetes version |
| `vpc_cidr` | string | 10.0.0.0/16 | VPC CIDR block |
| `node_desired_size` | number | 3 | Desired number of nodes |
| `node_min_size` | number | 2 | Minimum nodes (for auto-scaling) |
| `node_max_size` | number | 6 | Maximum nodes (for auto-scaling) |
| `node_instance_types` | list | ["t3.medium"] | EC2 instance types for nodes |
| `enable_nat_gateway` | bool | true | Enable NAT Gateway for private subnets |
| `single_nat_gateway` | bool | false | Use single NAT (cost-saving) or one per AZ |
| `enable_monitoring` | bool | true | Enable CloudWatch logging |

### File Structure

```
TF-EKS/
├── main.tf                    # Provider configuration
├── variables.tf               # Variable definitions
├── vpc.tf                     # VPC, subnets, route tables
├── eks.tf                     # EKS cluster configuration
├── eks-node-group.tf         # Worker node configuration
├── outputs.tf                # Output values
├── terraform.tfvars.example  # Example variables file
├── .gitignore               # Git ignore rules
└── README.md                # This file
```

## Cluster Access

### Configure kubectl

```bash
# Automatic configuration
aws eks update-kubeconfig --region us-east-1 --name production-eks

# Verify connection
kubectl cluster-info
```

### Using IAM Authentication

The EKS cluster uses IAM for authentication. Your AWS credentials must have permissions to assume the EKS cluster IAM role.

### RBAC and Access Control

By default, only the AWS account that created the cluster has access. To grant access to other IAM users or roles:

```bash
# Edit the aws-auth ConfigMap
kubectl edit configmap aws-auth -n kube-system

# Add IAM user/role under mapUsers or mapRoles section
```

Example:

```yaml
mapUsers: |
  - userarn: arn:aws:iam::ACCOUNT_ID:user/USERNAME
    username: USERNAME
    groups:
      - system:masters
```

## Monitoring and Logging

### CloudWatch Logs

CloudWatch logging is enabled by default for:
- API server logs
- Audit logs
- Authenticator logs
- Controller manager logs
- Scheduler logs

View logs in AWS Console:
```
CloudWatch → Logs → /aws/eks/production-eks/cluster
```

Or using AWS CLI:

```bash
aws logs tail /aws/eks/production-eks/cluster --follow
```

### Prometheus and Grafana (Optional)

For advanced monitoring, install Prometheus and Grafana:

```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

### CloudWatch Container Insights

Enable Container Insights for additional monitoring:

```bash
# Install CloudWatch agent
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml
```

## Scaling

### Horizontal Pod Autoscaling (HPA)

```bash
# Install metrics-server (required for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Create HPA
kubectl autoscale deployment nginx --min=2 --max=10 --cpu-percent=80 -n default
```

### Cluster Autoscaling

Cluster Autoscaling is ready to use. Deploy using Helm:

```bash
# Add Helm repository
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

# Install Cluster Autoscaler
helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  -n kube-system \
  --set autoDiscovery.clusterName=production-eks \
  --set awsRegion=us-east-1
```

### Scaling Nodes Manually

```bash
# Increase desired node count in terraform.tfvars
node_desired_size = 5

# Apply changes
terraform apply
```

## Maintenance

### Updating Kubernetes Version

**Important:** Always backup your data before upgrading.

1. Update `cluster_version` in `terraform.tfvars`
2. Run `terraform plan` to review changes
3. Run `terraform apply` to update

```bash
# In terraform.tfvars
cluster_version = "1.30"  # Update to new version

terraform plan
terraform apply
```

### Updating Node AMI

Node AMI updates are handled automatically by AWS. New nodes will use the latest AMI during scale-up events.

### Backup Strategy

```bash
# Install Velero for backup/restore
helm repo add velero https://vmware-tanzu.github.io/helm-charts
helm repo update

helm install velero velero/velero \
  --namespace velero \
  --create-namespace \
  --set configuration.backupStorageLocation.bucket=my-backup-bucket \
  --set configuration.schedules.daily.schedule="0 2 * * *"
```

## Cleanup

To destroy all infrastructure and avoid ongoing charges:

```bash
# Destroy all resources
terraform destroy

# Confirm the destruction when prompted
```

**Important:** This action will:
- Delete the EKS cluster
- Delete all worker nodes
- Delete the VPC and related resources
- Delete IAM roles and policies
- Delete CloudWatch log groups (if created)

**Data Loss:** Any data stored in cluster will be lost. Ensure backups exist.

## Best Practices

### 1. State Management
- Use S3 backend with encryption and versioning enabled
- Enable state locking using DynamoDB
- Never commit `terraform.tfstate` files to version control

**Setup Remote State:**

```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket tf-state-${ACCOUNT_ID} \
  --region us-east-1 \
  --acl private

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket tf-state-${ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket tf-state-${ACCOUNT_ID} \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

Update `main.tf`:

```hcl
backend "s3" {
  bucket         = "tf-state-123456789"
  key            = "eks/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

### 2. Security

- Use private subnets for worker nodes
- Enable VPC Flow Logs for security monitoring
- Implement Network Policies in Kubernetes
- Use IRSA for pod-level IAM permissions
- Enable Pod Security Standards (PSS)
- Implement OPA/Gatekeeper for policy enforcement

### 3. Networking

- Use separate subnets for public and private resources
- Configure security groups with least privilege
- Enable VPC Flow Logs for troubleshooting
- Use multiple NAT Gateways for redundancy (production)
- Implement Kubernetes CNI security policies

### 4. Monitoring and Logging

- Enable CloudWatch logs for EKS control plane
- Deploy prometheus/Grafana for metrics
- Implement centralized logging (ELK, Splunk)
- Set up alerts for critical metrics
- Use CloudWatch Container Insights

### 5. Cost Optimization

- Use spot instances for non-critical workloads
- Right-size instance types based on workload
- Use single NAT Gateway for dev/test environments
- Enable cluster autoscaling
- Monitor costs using AWS Cost Explorer

### 6. High Availability

- Deploy across multiple availability zones (default)
- Configure pod disruption budgets
- Implement pod replica guidelines
- Use Network Policies for security
- Set up multi-region failover (optional)

### 7. GitOps Workflow

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Manage infrastructure as code with git
```

## Troubleshooting

### Issue: Nodes are not joining the cluster

**Solution:**
```bash
# Check node logs
kubectl get nodes
kubectl describe node <node-name>

# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:aws:cloudformation:stack-name,Values=eks-*"
```

### Issue: Cannot access cluster

**Solution:**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check security groups
aws ec2 describe-security-groups --group-ids <security-group-id>

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name production-eks
```

### Issue: Pod cannot reach external services

**Solution:**
```bash
# Check NAT Gateway
aws ec2 describe-nat-gateways

# Verify route tables
aws ec2 describe-route-tables

# Check security groups
kubectl get pods -o wide
aws ec2 describe-security-groups --group-ids <node-sg-id>
```

### Issue: High costs

**Optimization:**
```hcl
# Reduce node count
node_desired_size = 1
node_min_size     = 1

# Use spot instances
instance_types = ["t3.large", "t3a.large"]  # Multiple types for spot

# Enable single NAT Gateway
single_nat_gateway = true
```

## Additional Resources

### Documentation
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Tools and Add-ons
- [eksctl - AWS EKS CLI](https://eksctl.io/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Helm - Package Manager for Kubernetes](https://helm.sh/)
- [ArgoCD - GitOps for Kubernetes](https://argo-cd.readthedocs.io/)

### Learning Resources
- [AWS EKS Workshop](https://www.eksworkshop.com/)
- [Kubernetes Learning Path](https://kubernetes.io/docs/tutorials/)
- [Terraform by HashiCorp](https://www.terraform.io/learn)

### Example Workloads
- [Kubernetes Examples](https://kubernetes.io/examples/)
- [Helm Charts](https://artifacthub.io/)
- [AWS Containers Roadmap](https://github.com/aws/containers-roadmap)

---

## Support and Contributing

For issues, questions, or contributions:
1. Check existing GitHub issues
2. Review the troubleshooting section
3. Create a new issue with detailed information
4. Include `terraform plan` output and logs

## License

This Terraform configuration is provided as-is for educational and production use.

---

**Last Updated:** October 2026
**Terraform Version:** >= 1.0
**AWS Provider Version:** >= 5.0
**Kubernetes Version:** >= 1.27
