# Variable block
variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "domain_name_simple" {
  description = "The root domain name, e.g., ekaterina-nutritionist.com"
  type        = string
}

variable "domain_name" {
  description = "The full domain name, e.g., www.ekaterina-nutritionist.com"
  type        = string
}
