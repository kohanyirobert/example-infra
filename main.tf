terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.76.0"
      configuration_aliases = [aws.eu]
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.5"
    }
  }

  backend "s3" {
    encrypt = true
  }

  required_version = "1.9.8"
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "eu"
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_regions" "all" {
  provider = aws.eu
}
