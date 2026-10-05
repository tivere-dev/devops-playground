variable "region" {
  description = "AWS region to create everything in"
  type        = string
  default     = "eu-west-2" # London. (Cape Town, af-south-1, must be enabled in your account first)
}

variable "instance_type" {
  description = "Server size. Check which sizes are Free Tier eligible on your account."
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Your public IP with /32, e.g. 102.89.1.2/32 - only this IP may SSH in"
  type        = string
}

variable "public_key_path" {
  description = "Your SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "app_image" {
  description = "Container image to run, e.g. ghcr.io/your-username/devops-playground:latest"
  type        = string
}
