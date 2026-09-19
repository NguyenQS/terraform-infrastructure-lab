variable "image_name" {
  description = "Docker image managed by Terraform"
  type        = string
  default     = "nginx:latest"
}

variable "container_name" {
  description = "Name of the Docker container"
  type        = string
  default     = "terraform-nginx"
}

variable "external_port" {
  description = "Port exposed on the host"
  type        = number
  default     = 8081
}

variable "network_names" {
  description = "Docker networks managed by Terraform"
  type        = set(string)
  default     = ["frontend", "backend"]
}