# AWS VPC Foundation - InfraCodeBase Sandbox

A secure, cost-aware AWS VPC foundation built with Terraform following InfraCodeBase principles. Perfect for learning, testing, and iterating on AWS infrastructure.

## Architecture Overview

This setup creates a production-ready VPC foundation with:

- **Custom VPC** (10.0.0.0/16) with 65,536 IP addresses
- **Multi-AZ Design** across 2 availability zones for high availability
- **Public Subnets** (2x) for internet-facing resources
- **Private Subnets** (2x) for internal resources and databases
- **Internet Gateway** for public internet access
- **NAT Gateway** for secure private subnet internet access
- **Properly Segmented Route Tables** for network security
- **Least-Privilege Security Groups** for web, app, database, and management tiers


##  Diagram

<img width="648" height="816" alt="Screenshot 2025-12-24 171208" src="https://github.com/user-attachments/assets/b3ca4ac9-0fad-433a-88e8-85dd55675b66" />

  

## Network Design

| Component | CIDR Block | Purpose |
|-----------|------------|---------|
| VPC | 10.0.0.0/16 | Main network (65,536 IPs) |
| Public Subnet 1 | 10.0.16.0/20 | Internet-facing resources AZ1 (4,094 IPs) |
| Public Subnet 2 | 10.0.32.0/20 | Internet-facing resources AZ2 (4,094 IPs) |
| Private Subnet 1 | 10.0.48.0/20 | Internal resources AZ1 (4,094 IPs) |
| Private Subnet 2 | 10.0.64.0/20 | Internal resources AZ2 (4,094 IPs) |

## Security Features

### Security Groups (Least Privilege)
- **Web Tier**: HTTP/HTTPS from internet, SSH from VPC
- **App Tier**: App ports from web tier only, SSH from management
- **Database Tier**: Database ports from app tier only, no internet access
- **Management**: Admin access for bastion hosts and management

### Network Security
- Default security group locked down (all rules removed)
- Private subnets with no direct internet access
- NAT Gateway for secure outbound internet from private subnets
- Separate route tables per tier

## Cost Optimization

### Current Configuration (Sandbox Optimized)
- **Single NAT Gateway** instead of one per AZ (~$22.5/month savings)
- **No VPN Gateway** (~$36/month savings)
- **Estimated Monthly Cost**: ~$45-50 (primarily NAT Gateway)

### Cost Reduction Options
```hcl
# In terraform.tfvars
enable_nat_gateway = false  # Save ~$45/month (breaks private subnet internet)
enable_vpn_gateway = false  # Save ~$36/month (default)
```

## Quick Start

### Prerequisites
1. AWS credentials configured in workspace secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_DEFAULT_REGION` (optional)

### Deploy Infrastructure
```bash
# 1. Copy and customize variables
cp terraform.tfvars.example terraform.tfvars

# 2. Initialize Terraform
terraform init

# 3. Review the plan
terraform plan

# 4. Apply infrastructure
terraform apply
```

### Validate Deployment
```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=infracode-sandbox-*"

# List subnets
aws ec2 describe-subnets --filters "Name=tag:Project,Values=infracode-sandbox"

# View NAT Gateways
aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=infracode-sandbox-*"
```

## File Structure

```
├── main.tf                    # Provider configuration and locals
├── variables.tf               # Input variables with validation
├── vpc.tf                     # VPC, subnets, gateways
├── routing.tf                 # Route tables and associations
├── security-groups.tf         # Security groups for all tiers
├── outputs.tf                 # Output values for other modules
├── terraform.tfvars.example   # Example configuration
├── .gitignore                 # Terraform and security best practices
└── README.md                  # This documentation
```

## Customization

### Change Region
```hcl
# In terraform.tfvars
aws_region = "us-east-1"  # or your preferred region
```

### Adjust Network CIDRs
```hcl
# In terraform.tfvars
vpc_cidr = "172.16.0.0/16"  # Change if you have conflicts
```

### Production Configuration
```hcl
# In terraform.tfvars
environment        = "prod"
single_nat_gateway = false  # High availability - one NAT per AZ
enable_vpn_gateway = true   # If site-to-site connectivity needed
```

## Security Best Practices Implemented

- ✅ Default security group locked down
- ✅ Least-privilege security group rules
- ✅ Private subnets with no direct internet access
- ✅ Explicit public IP assignment (disabled by default)
- ✅ DNS hostnames enabled for AWS services
- ✅ Proper resource tagging for governance
- ✅ Secrets excluded from git (.gitignore)

## Next Steps

After deploying this foundation, you can:

1. **Add Compute**: Launch EC2 instances in appropriate subnets
2. **Database Layer**: Deploy RDS in private subnets with database security group
3. **Load Balancing**: Add ALB in public subnets for high availability
4. **Monitoring**: Implement CloudWatch, VPC Flow Logs
5. **Security**: Add WAF, GuardDuty, Security Hub

## Cleanup

```bash
# Destroy all resources (be careful!)
terraform destroy

# Or delete specific resources
terraform destroy -target=aws_nat_gateway.main
```

## Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [InfraCodeBase Principles](https://infracodebase.com/)

---

**Built with InfraCodeBase for secure, maintainable infrastructure**
