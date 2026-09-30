terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in ap-south-1 (used for SSH access)"
  type        = string
  default     = "portfolio_key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance (e.g. your IP/32)"
  type        = string
  default     = "0.0.0.0/0"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-docker-sg"
  description = "Allow SSH, Jenkins UI, and HTTP/HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Jenkins UI"
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
    Name = "jenkins-docker-sg"
  }
}

resource "aws_instance" "my_ec2" {
  ami                    = "ami-006f82a1d5a27da54"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "jenkins-docker-Terra"
  }
}

output "instance_id" {
  value = aws_instance.my_ec2.id
}

output "public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.my_ec2.public_ip}:8080"
}
