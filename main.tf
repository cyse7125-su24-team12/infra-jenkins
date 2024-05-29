terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "jenkins_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "jenkins_subnet" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "jenkins_vpc_gw" {
  vpc_id = aws_vpc.jenkins_vpc.id
}

resource "aws_route_table" "jenkins_subnet_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_vpc_gw.id
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.jenkins_subnet_rt.id
}

resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_instance"
  }
}

resource "aws_security_group" "http_8080" {
  vpc_id = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_instance"
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-08c1a6e9e03462636"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.jenkins_subnet.id
  security_groups = [
    aws_security_group.ssh.id,
    aws_security_group.http_8080.id
  ]

  tags = {
    Name = "jenkins_instance"
  }
}

data "aws_eip" "existing_eip" {
  public_ip = "34.232.103.26"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = data.aws_eip.existing_eip.id
}