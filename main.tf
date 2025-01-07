terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.2"
        }
    }
}
provider "aws" {
    profile = "devops"
    region = "ap-south-2"
}


# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Define the CIDR block for the VPC
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "MainIGW"
  }
}

# Create public subnets (adjust CIDR ranges based on your needs)
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"  # Public subnet 1
  availability_zone       = "ap-south-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnetA"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"  # Public subnet 2
  availability_zone       = "ap-south-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnetB"
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "PublicRouteTable"
  }
}

# Add route to the route table to allow internet access
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Outputs to verify the setup
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_a_id" {
  value = aws_subnet.subnet_a.id
}

output "subnet_b_id" {
  value = aws_subnet.subnet_b.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}
