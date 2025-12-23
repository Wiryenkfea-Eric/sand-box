# Security Groups - Network-level security with least-privilege access
# Following AWS security best practices

# Default Security Group Rules Cleanup
# Remove default rules from the VPC default security group for security
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # No ingress or egress rules = deny all traffic
  # This forces explicit security group creation

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-default-sg-locked"
    Type = "default-security-group"
    Note = "All rules removed for security - use explicit security groups"
  })
}

# Web Tier Security Group - For public-facing web servers
resource "aws_security_group" "web_tier" {
  name_prefix = "${local.name_prefix}-web-"
  description = "Security group for web tier (public-facing)"
  vpc_id      = aws_vpc.main.id

  # HTTP access from anywhere
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from management networks only (customize as needed)
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound internet access (for updates, APIs, etc.)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-sg"
    Type = "security-group"
    Tier = "web"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Application Tier Security Group - For internal application servers
resource "aws_security_group" "app_tier" {
  name_prefix = "${local.name_prefix}-app-"
  description = "Security group for application tier (internal)"
  vpc_id      = aws_vpc.main.id

  # Application port access from web tier only
  ingress {
    description     = "App port from web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]
  }

  # Alternative app port
  ingress {
    description     = "Alt app port from web tier"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]
  }

  # SSH access from management security group
  ingress {
    description     = "SSH from management"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.management.id]
  }

  # Outbound internet access for updates and external APIs
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
    Type = "security-group"
    Tier = "application"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database Tier Security Group - For database servers
resource "aws_security_group" "database_tier" {
  name_prefix = "${local.name_prefix}-db-"
  description = "Security group for database tier (private)"
  vpc_id      = aws_vpc.main.id

  # MySQL/Aurora access from application tier
  ingress {
    description     = "MySQL from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }

  # PostgreSQL access from application tier
  ingress {
    description     = "PostgreSQL from app tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }

  # MongoDB access from application tier
  ingress {
    description     = "MongoDB from app tier"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }

  # Redis/ElastiCache access from application tier
  ingress {
    description     = "Redis from app tier"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }

  # No outbound rules = no internet access (secure by default)
  # Add specific egress rules if database needs external access

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-sg"
    Type = "security-group"
    Tier = "database"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Management Security Group - For bastion hosts and admin access
resource "aws_security_group" "management" {
  name_prefix = "${local.name_prefix}-mgmt-"
  description = "Security group for management and bastion hosts"
  vpc_id      = aws_vpc.main.id

  # SSH access from trusted IP ranges (customize as needed)
  ingress {
    description = "SSH from trusted networks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # CHANGE THIS: Replace with your actual IP ranges
  }

  # HTTPS for admin interfaces
  ingress {
    description = "HTTPS admin access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # CHANGE THIS: Replace with your actual IP ranges
  }

  # Outbound access for management tools
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-mgmt-sg"
    Type = "security-group"
    Tier = "management"
  })

  lifecycle {
    create_before_destroy = true
  }
}