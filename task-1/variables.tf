variable "region" {
   default = "us-east-1"
}
variable "vpc_cidr" {
   default = "10.0.0.0/16"
}
variable "environment" {
   type = string
   default = "dev"
}
variable "public_subnets_cidr" {
   default = "10.0.0.0/24"
}
variable "availability_zones" {
   default = "us-east-1c"
}
variable "private_subnets_cidr" {
   default = "10.0.1.0/24"
}
variable "webserver_instance_type" {
   default = "t2.micro"
}
variable "db_instance_type" {
   default = "t2.micro"
}
variable "key_name" {
   default = "raj-dev"
}
variable "ebs_optimized" {
   default = "true"
}
variable "webserver_ips"  {
   default = "10.0.0.5"
}
variable "db_ips" {
   default = "10.0.1.5"
}
