output "public_ip" {
  description = "The server's public IP address"
  value       = aws_instance.web.public_ip
}

output "website" {
  value = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  value = "ssh ubuntu@${aws_instance.web.public_ip}"
}
