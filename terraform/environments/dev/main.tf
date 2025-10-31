terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
    random = { source = "hashicorp/random" }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" { 
    type = string 
    default = "eu-west-1" 
    }

module "network" {
  source = "../../modules/network"
  vpc_cidr = "10.21.0.0/16"
  subnet_cidr = "10.21.1.0/24"
}

resource "random_id" "r" { byte_length = 4 }

module "storage" {
  source = "../../modules/storage"
  bucket_name = "presentation-app-dev-${random_id.r.hex}"
}

module "compute" {
  source = "../../modules/compute"
  vpc_id = module.network.vpc_id
  subnet_id = module.network.subnet_id
  instance_type = "t3.micro"
  key_name = ""                # fill if you want SSH access
  app_port = 8000
  app_repo_url = "https://github.com/csoszi/terraform-presentation-python.git"
}