variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "eu-central-1"
}

variable "main_vpc" {
  type    = string
  default = "Main VPC"
}

variable "main_vpc_cidr" {
  description = "cidr block for main vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Available cidr for the public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr" {
  description = "Available cidr for the private subnet"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "subnet_endpoint_cidr" {
  description = "Available cidr for the private subnet"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

variable "public_route_table" {
  description = "define o nome do route table"
  type        = string
  default     = "0.0.0.0/0"

}

variable "private_route_table" {
  description = "define o nome do route table"
  type        = string
  default     = "0.0.0.0/0"

}

variable "endpoint_route_table" {
  description = "define o nome do route table"
  type        = string
  default     = "0.0.0.0/0"

}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

###############
#    NAMES    #
###############

variable "vpc_name" {
  type    = string
  default = "VPC de um resetado"
}

variable "public_subnet_name" {
  type    = string
  default = "Public Subnet"
}

variable "private_subnet_name" {
  type    = string
  default = "Private Subnet"
}

variable "endpoint_subnet_name" {
  type    = string
  default = "Endpoint Subnet"
}

variable "nat_name" {
  type    = string
  default = "Nat Gateway"
}

variable "publicrtname" {
  type    = string
  default = "Public Route Table"
}

variable "privatertname" {
  type    = string
  default = "Private Route Table"
}

variable "endpointrtname" {
  type    = string
  default = "Endpoint Route Table"
}