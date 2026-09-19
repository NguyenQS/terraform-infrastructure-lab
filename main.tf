provider "docker" {
  context = "desktop-linux"
}

locals {
  service_label = "${var.container_name}:${var.external_port}"
}

resource "docker_image" "nginx" {
  name = var.image_name
}

resource "docker_container" "web" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.external_port
  }

  networks_advanced {
    name = docker_network.networks["frontend"].name
  }
}

resource "docker_network" "networks" {
  for_each = var.network_names

  name = "terraform-${each.value}"
}
