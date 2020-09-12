variable "vpc_cidr_block" {
  type = string
  description = ""
}

variable "public_subnet_cidr" {
  type = list
}

variable "private_subnet_cidr" {
  type = list
}

variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "eip_count" {
  type = string
}
