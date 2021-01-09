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
  default     = "subnet-4a98c707"
}

variable "vpcid" {
  description = "Vpc to be used for Instance "
  default     = "vpc-bb4c94c6"
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
  default     = "34.228.57.151/32"
}

variable "PvtIp" {
  description = " subnet IP to be allowed SSH for"
  default     = "172.31.0.0/16"
}
