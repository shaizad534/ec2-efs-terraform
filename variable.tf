# Variables TF File
variable "region" {
  description = "AWS Region "
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to be used for Instance "
  default     = "ami-0be2609ba883822ec"
}

variable "instancetype" {
  description = "Instance Type to be used for Instance "
  default     = "t2.micro"
}

variable "subnetid" {
  description = "Subnet ID to be used for Instance "
  default     = "subnet-d291e59f"
}

variable "vpcid" {
  description = "Vpc to be used for Instance "
  default     = "vpc-4cbd4d31"
}


variable "AppName" {
  description = "Application Name"
  default     = "poc-server"
}

variable "Env" {
  description = "Application Name"
  default     = "Poc"
}

variable "HostIp" {
  description = " Host IP to be allowed SSH for"
  default     = "98.206.221.201/32"
}

variable "PvtIp" {
  description = " subnet IP to be allowed SSH for"
  default     = "172.31.16.0/20"
}
