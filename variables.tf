# Variable block
variable "domain_name_simple" {
  description = "The root domain name, e.g., ekaterina-nutritionist.com"
  type        = string
  default     = "ekaterina-nutritionist.com"
}

variable "domain_name" {
  description = "The full domain name, e.g., www.ekaterina-nutritionist.com"
  type        = string
  default     = "www.ekaterina-nutritionist.com"
}
