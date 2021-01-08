# Outputs.tf
output "instance_id" {
  description = " Instance ID of the instance"
  value       = aws_instance.poc-server.id
}

output "instance_IP" {
  description = " Public IP of the instance"
  value       = aws_instance.poc-server.public_ip
}

output "Efs_id" {
  description = " Efs id of the Elastic filesystem"
  value       = aws_efs_file_system.poc-efs.id
}

output "private_key" {
  description = "Key of the ec2 instance "
  value       = tls_private_key.tmp.private_key_pem
}
