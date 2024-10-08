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
    profile = "default"
    region = var.region
}

provider "aws" {
    alias   = "use_default_region"
    profile = "default"
    region  = var.region
}