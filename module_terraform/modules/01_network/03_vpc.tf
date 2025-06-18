# ================================================
# VPC
# ================================================
resource "aws_vpc" "this" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    Name = "sample-dev-vpc"
  }
}

# ================================================
# Internet Gateway
# ================================================
resource "aws_internet_gateway" "this" {
  tags = {
    Name = "sample-dev-igw"
  }
  vpc_id = aws_vpc.this.id
}

# ================================================
# NAT Gateway
# ================================================
resource "aws_nat_gateway" "nat_a" {
  count             = var.create_nat_gateway ? 1 : 0
  allocation_id     = aws_eip.nat_a[count.index].id
  connectivity_type = "public"
  # private_ip                         = "10.0.1.10"
  subnet_id = resource.aws_subnet.public_a.id
  tags = {
    Name = "sample-dev-nat-a"
  }
}

# ================================================
# EIP
# ================================================
resource "aws_eip" "nat_a" {
  count                = var.create_nat_gateway ? 1 : 0
  domain               = "vpc"
  network_border_group = "ap-southeast-2"
  public_ipv4_pool     = "amazon"
  tags = {
    Name = "sample-dev-nat-a"
  }
}


# ================================================
# S3 VPC Endpoint (Gateway) 
# ================================================
resource "aws_vpc_endpoint" "s3" {
  policy = jsonencode({
    Statement = [{
      Action    = "*"
      Effect    = "Allow"
      Principal = "*"
      Resource  = "*"
    }]
    Version = "2008-10-17"
  })
  private_dns_enabled = false
  route_table_ids     = [aws_route_table.public_rtb.id, aws_route_table.protected_rtb_a.id, aws_route_table.protected_rtb_c.id]
  security_group_ids  = []
  service_name        = "com.amazonaws.ap-southeast-2.s3"
  vpc_endpoint_type   = "Gateway"
  vpc_id              = aws_vpc.this.id
  tags = {
    Name = "sample-dev-vpce-s3"
  }
}

# ================================================
# DynamoDB VPC Endpoint (Gateway) 
# ================================================
resource "aws_vpc_endpoint" "dynamodb" {
  policy = jsonencode({
    Statement = [{
      Action    = "*"
      Effect    = "Allow"
      Principal = "*"
      Resource  = "*"
    }]
    Version = "2008-10-17"
  })
  private_dns_enabled = false
  route_table_ids     = [aws_route_table.public_rtb.id, aws_route_table.protected_rtb_a.id, aws_route_table.protected_rtb_c.id]
  security_group_ids  = []
  service_name        = "com.amazonaws.ap-southeast-2.dynamodb"
  vpc_endpoint_type   = "Gateway"
  vpc_id              = aws_vpc.this.id
  tags = {
    Name = "sample-dev-vpce-dynamodb"
  }
}
