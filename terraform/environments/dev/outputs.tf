output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.compute.instance_public_ip
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = module.compute.instance_id
}

output "bucket_name" {
  description = "Name of the S3 bucket used for app storage"
  value       = module.storage.bucket_name
}
