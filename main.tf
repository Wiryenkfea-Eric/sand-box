# AWS VPC Foundation - InfraCodeBase Sandbox
# Secure, cost-aware VPC setup for learning and testing
# This creates a production-ready VPC foundation with proper security boundaries

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Best practice: Use consistent tagging across all resources
  default_tags {
    tags = {
      Project     = "InfraCodeBase-Sandbox"
      Environment = "sandbox"
      ManagedBy   = "terraform"
      Owner       = "learning"
    }
  }
}

# Data sources for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for consistent naming and configuration
locals {
  # Naming conventions
  name_prefix = "${var.project_name}-${var.environment}"

  # Network configuration
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  # CIDR calculations for subnets
  public_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 4, 1), # 10.0.16.0/20 (4094 IPs)
    cidrsubnet(var.vpc_cidr, 4, 2)  # 10.0.32.0/20 (4094 IPs)
  ]

  private_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 4, 3), # 10.0.48.0/20 (4094 IPs)
    cidrsubnet(var.vpc_cidr, 4, 4)  # 10.0.64.0/20 (4094 IPs)
  ]

  # Common tags
  common_tags = {
    Name        = local.name_prefix
    Project     = var.project_name
    Environment = var.environment
  }
}