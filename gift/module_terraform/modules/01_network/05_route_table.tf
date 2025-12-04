# ================================================
# Public Route Table
# ================================================
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "sample-dev-public-rtb"
  }
}

# ================================================
# Protected Route Table
# ================================================
resource "aws_route_table" "protected_rtb_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "sample-dev-protected-rtb-a"
  }
}

resource "aws_route_table" "protected_rtb_c" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "sample-dev-protected-rtb-c"
  }
}

# ================================================
# Private Route Table
# ================================================
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "sample-dev-private-rtb"
  }
}



# ================================================
# Public Route
# ================================================
resource "aws_route" "public_rtb_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  route_table_id         = aws_route_table.public_rtb.id
}

# ================================================
# Protected Route A
# ================================================
resource "aws_route" "protected_rtb_a_ngw" {
  count                  = var.create_nat_gateway ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a[count.index].id
  route_table_id         = aws_route_table.protected_rtb_a.id
}

# ================================================
# Protected Route C
# ================================================
resource "aws_route" "protected_rtb_c_ngw" {
  count                  = var.create_nat_gateway ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a[count.index].id
  route_table_id         = aws_route_table.protected_rtb_c.id
}



# ================================================
# Public Route Table Association
# ================================================
resource "aws_route_table_association" "public_a" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id      = aws_subnet.public_a.id
}

resource "aws_route_table_association" "public_c" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id      = aws_subnet.public_c.id
}

# ================================================
# Protected Route Table Association
# ================================================
resource "aws_route_table_association" "protected_a" {
  route_table_id = aws_route_table.protected_rtb_a.id
  subnet_id      = aws_subnet.protected_a.id
}

resource "aws_route_table_association" "protected_c" {
  route_table_id = aws_route_table.protected_rtb_c.id
  subnet_id      = aws_subnet.protected_c.id
}

# ================================================
# Private Route Table Association
# ================================================
resource "aws_route_table_association" "private_a" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.private_a.id
}

resource "aws_route_table_association" "private_c" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.private_c.id
}
