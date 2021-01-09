# Create key using awscli
# aws ec2 create-key-pair --key-name poc-server --query 'KeyMaterial' --output text >poc-server.pem
#

provider "aws" {
  region = var.region
}

# SSH access and a key-pair to access the instance
# Generate new private key

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

# Generate a key-pair with above key

resource "aws_key_pair" "deployer" {
  key_name   = "my-efs-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Saving Key Pair for ssh login for Client if needed
resource "null_resource" "save_key_pair" {
  provisioner "local-exec" {
    command = "echo ${tls_private_key.my_key.private_key_pem} > my-efs-key.pem"
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

resource "aws_instance" "poc-server" {
  ami                    = var.ami_id
  instance_type          = var.instancetype
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = var.subnetid
  depends_on             = [aws_efs_mount_target.mount]
  vpc_security_group_ids = [aws_security_group.poc-server.id]

  tags = {
    Name = var.AppName
    Env  = var.Env
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    inline = [
      # mount EFS volume
      # https://docs.aws.amazon.com/efs/latest/ug/gs-step-three-connect-to-ec2-instance.html
      # create a directory to mount our efs volume to
      #"sudo mkdir -p /mnt/efs",
      # mount the efs volume
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.poc-efs.dns_name}:/ /home",
      # create fstab entry to ensure automount on reboots
      # https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html#mount-fs-auto-mount-on-creation
      "sudo su -c \"echo '${aws_efs_file_system.poc-efs.dns_name}:/ /home nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab\"" #create fstab entry to ensure automount on reboots
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.my_key.private_key_pem
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

# Backend for terraform statestore

terraform {
  backend "s3" {
    bucket = "state-tf-backend"
    key    = "efs-ec2-tf/terraform.tfstate"
    region = "us-east-1"
  }
}

