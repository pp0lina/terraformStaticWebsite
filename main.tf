# Provider block
provider "aws" {
    profile = "default"
    region = "us-west-2"
}

# Resources Block
resource "aws instance" "project_server" {
    ami
}

#