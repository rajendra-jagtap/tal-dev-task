####################################

provider "aws" {
    region = "${var.region}"
}

####################################

# provider "ansible" {
#  version = "1.0.4"
# }

terraform {
  required_providers {
    ansible = {
      source = "nbering/ansible"
      version = "1.0.4"
    }
  }
}
provider "ansible" {}

####################################

terraform {
  backend "s3" {
    bucket = "rj-dev"
    key = "terrform/terraform.tfstate"
    region = "us-east-1"
   }
}

###################################

data "aws_caller_identity" "current" {}

###################################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name      = "name"
    values    = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name      = "owner-alias"
    values    = ["amazon"]
  }
}
