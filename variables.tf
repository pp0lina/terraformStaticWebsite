# Variable block
variable "domain_name_simple" {
  description = "The root domain name, e.g., example.com"
  type        = string
}

variable "domain_name" {
  description = "The full domain name, e.g., www.example.com"
  type        = string
}
