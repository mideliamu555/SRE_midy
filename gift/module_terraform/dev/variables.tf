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
    owner_id = "555750989087" # 実際のAWSアカウントIDに置き換えてください
    sysname  = "sample"
    env      = "dev"
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2" # Sydney region
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

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "sample-container"
}

variable "container_port" {
  description = "Port number for the container"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memory for the ECS task"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}