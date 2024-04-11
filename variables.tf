variable "aws_access_key"{
        default = " "  #Enter your access_key 
}
variable "aws_secret_key" {
        default = " "  #Enter your secret_access_key
}
variable "region" {
  default = "us-east-1" # Change to your desired AWS region
}
variable "instance_type" {
  default = "t2.micro" # Change to your desired EC2 instance type
}
variable "desired_capacity" {
  default = 2 # Change to your desired initial capacity
}
variable "min_size" {
  default = 1 # Change to your desired minimum size
}
variable "max_size" {
  default = 4 # Change to your desired maximum size
}
variable "key_name" {
  default = "xxxxxxxxxx" # Change to your EC2 key pair name
}
variable "ami" {
  default = "ami-xxxxxxxxxxxxxxxxx" # Change to your desired AMI ID
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16" # Change to your desired VPC CIDR block
}

variable "public_subnet_cidr_block" {
  default = "10.0.1.0/24" # Change to your desired public subnet CIDR block
}

variable "public_subnet_cidr_block_b" {
  default = "10.0.2.0/24" # Change to your desired public subnet CIDR block
}

variable "private_subnet_cidr_block" {
  default = "10.0.3.0/24" # Change to your desired private subnet CIDR block
}

variable "security_group_id" {
  default = "terrasg"
}
