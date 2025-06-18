# ================================================
# Common Settings
# ================================================
variable "common" {
  description = "Common settings for all resources"
  type = object({
    owner_id = string
    sysname  = string
    env      = string
  })
  default = {
    owner_id = "555750989087"  # 実際のAWSアカウントIDに置き換えてください
    sysname  = "sample"
    env      = "dev"
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"  # Sydney region
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway"
  type        = bool
  default     = true
}

variable "codecommit_repository_name" {
  description = "Name of the CodeCommit repository"
  type        = string
  default     = "sample-dev-ecs-deployment"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "sample"
    ManagedBy   = "terraform"
  }
}