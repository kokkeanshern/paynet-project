# VPC
resource "aws_vpc" "paynet-project-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "paynet-project-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "paynet-project-public-subnet" {
  vpc_id                  = aws_vpc.paynet-project-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "paynet-project-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "paynet-project-internet-gateway" {
  vpc_id = aws_vpc.paynet-project-vpc.id

  tags = {
    Name = "paynet-project-internet-gateway"
  }
}

# Route Table
resource "aws_route_table" "paynet-project-public-route-table" {
  vpc_id = aws_vpc.paynet-project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.paynet-project-internet-gateway.id
  }

  tags = {
    Name = "paynet-project-public-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "route-table-subnet-association" {
  subnet_id      = aws_subnet.paynet-project-public-subnet.id
  route_table_id = aws_route_table.paynet-project-public-route-table.id
}

# Security Group
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.paynet-project-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # allow SSH from anywhere (secure this for prod)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}
