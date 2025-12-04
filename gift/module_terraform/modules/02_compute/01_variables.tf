variable "vpc_id" {
  description = "VPC ID where the EFS will be created"
  type        = string
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway"
  type        = bool
  default     = false
}

variable "subnet" {
  description = "Map of subnet IDs"
  type = object({
    public_a_id     = string
    public_c_id     = string
    protected_a_id  = string
    protected_c_id  = string
  })
}

variable "security_group" {
  description = "Map of security group IDs"
  type = object({
    fargate_ecs_task_id = string
  })
}

variable "target_group" {
  description = "Map of target group information"
  type = object({
    fargate01_arn  = string
    fargate01_name = string
    fargate02_arn  = string
    fargate02_name = string
  })
}

variable "alb_listener" {
  description = "Map of ALB listener ARNs"
  type = object({
    alb_80_arn   = string
    alb_8080_arn = string
  })
}

variable "codecommit_repository_name" {
  description = "Name of the CodeCommit repository containing appspec.yaml"
  type        = string
}