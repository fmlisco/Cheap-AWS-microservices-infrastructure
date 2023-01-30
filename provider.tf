terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
  }

  required_version = "~> 1.3"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}