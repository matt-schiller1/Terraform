# Provider Block
provider "aws" {
  profile = "default"
  region = "us-west-1"
}

# Resource Block

# VPC
resource "aws_vpc" "matts_awesome_cloud" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "matts_awesome_cloud"
  }
}

# Subnet (Public)
resource "aws_subnet" "matts_awesome_subnet" {
  vpc_id = aws_vpc.matts_awesome_cloud.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "matts_awesome_subnet"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "matts_awesome_IG" {
  vpc_id = aws_vpc.matts_awesome_cloud.id
  tags = {
    Name = "matts_awesome_gateway"
  }
}

# Route Table and Association

resource "aws_route_table" "matts_awesome_RT" {
  vpc_id = aws_vpc.matts_awesome_cloud.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.matts_awesome_IG.id
  }
  tags = {
    Name = "matts_awesome_RT"
  }
}

resource "aws_route_table_association" "matts_awesome_association" {
  subnet_id = aws_subnet.matts_awesome_subnet.id
  route_table_id = aws_route_table.matts_awesome_RT.id
}

# Security Groups
resource "aws_security_group" "matts_secure_SG" {
  name = "matts_secure_SG"
  description = "To allow inbound and outbound traffic"
  vpc_id = aws_vpc.matts_awesome_cloud.id

  // Create Inbound and Outbound Traffic

  dynamic ingress {
    iterator = port
    for_each = var.ports
    content {
        from_port = port.value
        to_port = port.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "matts_awesome_SG"
  }
}

#EC2
resource "aws_instance" "matts_jenkins_instance" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.matts_secure_SG.id]
    subnet_id = aws_subnet.matts_awesome_subnet.id
    associate_public_ip_address = true
    
    user_data = file("./installJenkins.sh")

    tags = {
        Name = "matts_jenkins_instance"
    }
}

