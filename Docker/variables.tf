variable "region" {
  description = "AWS region"
  type = string
}

variable "profile" {
  description = "AWS profile"
  type = string
}

variable "my_ip" {
  description = "allowed CIDR"
  type = string
  sensitive = true
}

variable "instance_type" {
  description = "Instance type"
  type = string
}

variable "kp" {
  description = "Key pair"
  type = string
}