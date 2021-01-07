# Create key using awscli
# aws ec2 create-key-pair --key-name poc-server --query 'KeyMaterial' --output text >poc-server.pem
#

provider "aws" {
  region = var.region
}

# EC2 resource

resource "aws_instance" "poc-server" {
  ami                    = var.ami_id
  instance_type          = var.instancetype
  key_name               = "poc-server"
  subnet_id              = var.subnetid
  vpc_security_group_ids = [aws_security_group.poc-server.id]

  user_data = file("user-data.sh")
  tags = {
    Name = var.AppName
    Env  = var.Env
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Adding Security Group for our Instance :

resource "aws_security_group" "poc-server" {
  name        = "poc-server-sg"
  description = "poc-server Security Group"
  vpc_id      = var.vpcid
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.HostIp]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.PvtIp]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Creating EFS File system

resource "aws_efs_file_system" "poc-efs" {
  creation_token   = "poc-efs"
  performance_mode = "generalPurpose"
  tags = {
    Name = "poc-efs"
  }
}

# mounting Efs File system.

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.poc-efs.id
  subnet_id       = var.subnetid
  security_groups = [aws_security_group.poc-server.id]
}
