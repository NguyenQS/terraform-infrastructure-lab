output "docker_image_name" {
  description = "Name of the Docker image managed by Terraform"
  value       = docker_image.nginx.name
}

output "service_label" {
  description = "Combined container name and exposed port"
  value       = local.service_label
}