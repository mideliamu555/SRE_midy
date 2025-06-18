# ================================================
# Public subnet
# ================================================
resource "aws_subnet" "public_a" {
  availability_zone                              = "ap-southeast-2a"
  cidr_block                                     = "10.0.1.0/24"
  tags = {
    Name = "sample-dev-public-subnet-a"
  }
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "public_c" {
  availability_zone                              = "ap-southeast-2c"
  cidr_block                                     = "10.0.2.0/24"
  tags = {
    Name = "sample-dev-public-subnet-c"
  }
  vpc_id = aws_vpc.this.id
}


# ================================================
# Protected subnet
# ================================================
resource "aws_subnet" "protected_a" {
  availability_zone                              = "ap-southeast-2a"
  cidr_block                                     = "10.0.3.0/24"
  tags = {
    Name = "sample-dev-protected-subnet-a"
  }
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "protected_c" {
  availability_zone                              = "ap-southeast-2c"
  cidr_block                                     = "10.0.4.0/24"
  tags = {
    Name = "sample-dev-protected-subnet-c"
  }
  vpc_id = aws_vpc.this.id
}

# ================================================
# Private subnet
# ================================================
resource "aws_subnet" "private_a" {
  availability_zone                              = "ap-southeast-2a"
  cidr_block                                     = "10.0.5.0/24"
  tags = {
    Name = "sample-dev-private-subnet-a"
  }
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "private_c" {
  availability_zone                              = "ap-southeast-2c"
  cidr_block                                     = "10.0.6.0/24"
  tags = {
    Name = "sample-dev-private-subnet-c"
  }
  vpc_id = aws_vpc.this.id
}
