# Provider block
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    alias   = "use_default_region"
    profile = "default"
    region = "us-east-1"
}