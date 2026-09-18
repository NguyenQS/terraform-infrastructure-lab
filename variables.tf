variable "image_name" {
  description = "Docker image managed by Terraform"
  type        = string
  default     = "nginx:latest"
}