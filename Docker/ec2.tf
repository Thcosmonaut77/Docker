provider "aws" {
  region  = var.region
  profile = var.profile
}

# Create a remote backend for your terraform

terraform {
  backend "s3" {
    bucket = "trippy-docker-tfstate"
    dynamodb_table = "app-state"
    key = "LockID"
    region = "us-east-1"
    profile = "default"
    
  }
}

# DEFAULT VPC
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default_vpc"
  }
}

# Get all availability zones
data "aws_availability_zones" "available_zones" {}

# Create default subnet in the first AZ
resource "aws_default_subnet" "subnet" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# SECURITY GROUP for EC2
resource "aws_security_group" "docker_sg" {
  name        = "Docker SG"
  description = "Allow access on ports 22, 80, 8080, and 443"
  vpc_id      = aws_default_vpc.default_vpc.id


  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "HTTP access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP access"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP access"
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP access"
    from_port   = 4747
    to_port     = 4747
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP access"
    from_port   = 7070
    to_port     = 7070
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Docker server security group"
  }
}

# UBUNTU AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2 INSTANCE
resource "aws_instance" "docker" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = var.instance_type
    subnet_id                   = aws_default_subnet.subnet.id
    vpc_security_group_ids      = [aws_security_group.docker_sg.id]
    key_name                    = var.kp
    user_data                   = file("install_docker.sh")

    tags = {
      Name = "Docker-server"
    }
  
}

# Print Docker Server URL
output "docker_url" {
    value = join("", ["http://", aws_instance.docker.public_ip])  
}