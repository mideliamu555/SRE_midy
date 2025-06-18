# ================================================
# Terraform configuration
# ================================================
terraform {
  required_version = ">1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.81"
    }
  }
}

# ================================================
# Provider - AWS
# ================================================
provider "aws" {
  region  = "ap-southeast-2"
  profile = "ver-session"  # MFA認証済みのプロファイルを使用
}

# # ================================================
# # Module
# # ================================================
# module "network" {
#   source             = "../modules/01_network"
#   create_nat_gateway = var.create_nat_gateway
# }

# module "compute" {
#   source             = "../modules/02_compute"
#   create_nat_gateway = var.create_nat_gateway
#   vpc_id            = module.network.vpc_id
#   subnet            = module.network.subnet
#   security_group    = module.network.security_group
#   target_group      = module.network.target_group
#   alb_listener      = module.network.alb_listener
#   codecommit_repository_name = var.codecommit_repository_name
# } 


# 以下のモジュールは不要なためコメントアウト
# module "database" {
#   source         = "../modules/03_database"
#   subnet         = module.network.subnet
#   security_group = module.network.security_group
# }
