variable "tld" {
  description = "TLD name, e.g. 'com' (without a . at the end)"
  type        = string
}

variable "domain" {
  description = "Domain name, e.g. 'example' (without a . at the end), to be appended to TLD"
  type        = string
}

variable "subdomain" {
  description = "Subdomain name, e.g. 'other' (without a . at the end), to be appended to domain and TLD"
  type        = string
}

variable "web_image_tag" {
  description = "Web container image tag"
  type        = string
}

variable "api_image_tag" {
  description = "API container image tag"
  type        = string
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

variable "github_oidc_subject" {
  description = "Subject to be trusted by IAM, e.g. 'yourgithubname/yourreponname:*'"
  type        = string
}

variable "db_password" {
  description = "Database password to be provisioned as an SSM parameter"
  sensitive   = true
  type        = string
}

variable "local_bash_executable_path" {
  description = "Path to Bash executable for local-exec provisioner on Windows"
  type        = string
  default     = "/bin/bash"
}

variable "web_min_count" {
  description = "Minimum number of instances in web ASG"
  type        = number
  default     = 0
  validation {
    condition     = var.web_min_count <= 0
    error_message = "Must be greater than equal to zero and less than or equal to 'web_desired_count'"
  }
}

variable "web_desired_count" {
  description = "Desired number of instances in web ASG"
  type        = number
  default     = 1
  validation {
    condition     = var.web_min_count <= var.web_desired_count
    error_message = "Must be greater than or equal to 'web_min_count' and less than or equal to 'var.web_max_count'"
  }
}

variable "web_max_count" {
  description = "Maximum number of instances in web ASG"
  type        = number
  default     = 3
  validation {
    condition     = var.web_desired_count <= var.web_max_count
    error_message = "Must be greater than or equal to 'var.web_desired_count'"
  }
}

variable "web_target_group_port" {
  description = "Default port for web LB target group (traffic and health checks too)"
  type        = number
  default     = 80
}

variable "web_target_group_health_check_path" {
  description = "Default path for web LB target group health checks too"
  type        = string
  default     = "/"
}

variable "web_listener_port" {
  description = "Default port for web LB traffic"
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
