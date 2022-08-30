variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
}

variable "username" {
  description = "User for SSH login"
  type        = string
}

variable "groupname" {
  description = "User groupname"
  type        = string
}

variable "ssh_private_key_file" {
  description = "Full filename with private key"
  type        = string
}

variable "sshport" {
  description = "SSH port"
  type        = number
  default     = 22
}

variable "playbook" {
  description = "Ansible playbook for process"
  type        = string
}