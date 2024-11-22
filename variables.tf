variable "domain" {
  type        = string
  description = "Domain name, e.g. example.com. (with a . at the end)"
}

variable "subdomain" {
  type        = string
  description = "Subdomain name, e.g. other. to be used and appended to 'domain'  (with a . at the end, e.g. other.example.com.)"
}

variable "region" {
  description = "AWS region name where resources will be created"
  type        = string
  default     = "eu-central-1"
  validation {
    condition     = contains(data.aws_regions.all.names, var.region)
    error_message = "The region must be one of the available AWS regions"
  }
}

variable "project" {
  description = "Value to be used to tag resources (as-is or as a prefix)"
  type        = string
  default     = "main"
}

variable "db_password" {
  description = "Database password to be provisioned as an SSM parameter"
  sensitive   = true
  type        = string
  default     = "secret"
}

variable "local_bash_executable_path" {
  description = "Path to Bash executable for local-exec provisioner on Windows"
  type        = string
  default     = "/bin/bash"
}

variable "frontend_min_count" {
  description = "Minimum number of instances in frontend ASG"
  type        = number
  default     = 0
  validation {
    condition     = var.frontend_min_count <= 0
    error_message = "Must be greater than equal to zero and less than or equal to 'frontend_desired_count'"
  }
}

variable "frontend_desired_count" {
  description = "Desired number of instances in frontend ASG"
  type        = number
  default     = 1
  validation {
    condition     = var.frontend_min_count <= var.frontend_desired_count
    error_message = "Must be greater than or equal to 'frontend_min_count' and less than or equal to 'var.frontend_max_count'"
  }
}

variable "frontend_max_count" {
  description = "Maximum number of instances in frontend ASG"
  type        = number
  default     = 3
  validation {
    condition     = var.frontend_desired_count <= var.frontend_max_count
    error_message = "Must be greater than or equal to 'var.frontend_desired_count'"
  }
}

variable "frontend_target_group_port" {
  description = "Default port for frontend LB target group (traffic and health checks too)"
  type        = number
  default     = 80
}

variable "frontend_target_group_health_check_path" {
  description = "Default path for frontend LB target group health checks too"
  type        = string
  default     = "/"
}

variable "frontend_listener_port" {
  description = "Default port for frontend LB traffic"
  type        = number
  default     = 80
}

variable "api_min_count" {
  description = "Minimum number of instances in api ASG"
  type        = number
  default     = 0
  validation {
    condition     = var.api_min_count <= 0
    error_message = "Must be greater than equal to zero and less than or equal to 'api_desired_count'"
  }
}

variable "api_desired_count" {
  description = "Desired number of instances in api ASG"
  type        = number
  default     = 1
  validation {
    condition     = var.api_min_count <= var.api_desired_count
    error_message = "Must be greater than or equal to 'api_min_count' and less than or equal to 'var.api_max_count'"
  }
}

variable "api_max_count" {
  description = "Maximum number of instances in api ASG"
  type        = number
  default     = 3
  validation {
    condition     = var.api_desired_count <= var.api_max_count
    error_message = "Must be greater than or equal to 'var.api_desired_count'"
  }
}

variable "api_target_group_port" {
  description = "Default port for api LB target group (traffic and health checks too)"
  type        = number
  default     = 80
}

variable "api_target_group_health_check_path" {
  description = "Default path for api LB target group health checks too"
  type        = string
  default     = "/api/cars"
}

variable "api_listener_port" {
  description = "Default port for api LB traffic"
  type        = number
  default     = 80
}
