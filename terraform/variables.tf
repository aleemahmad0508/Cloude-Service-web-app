variable "aws_region" {
  description = "AWS region where the server will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-linux-server"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "cloudnotes"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "cloudadmin"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}