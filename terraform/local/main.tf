# Terraform practice on your Mac: create Docker containers with code (no cloud, no cost).
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Talk to Docker Desktop through its socket
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

variable "web_count" {
  description = "How many web containers to run"
  type        = number
  default     = 2
}

resource "docker_network" "tf_net" {
  name = "tf-net"
}

resource "docker_image" "nginx" {
  name         = "nginx:1.27-alpine"
  keep_locally = true # don't delete the image on terraform destroy
}

resource "docker_container" "web" {
  count = var.web_count
  name  = "tf-web-${count.index}"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.tf_net.name
  }

  ports {
    internal = 80
    external = 8100 + count.index # tf-web-0 -> 8100, tf-web-1 -> 8101 ...
  }
}

output "urls" {
  description = "Open these in your browser"
  value       = [for i in range(var.web_count) : "http://localhost:${8100 + i}"]
}
