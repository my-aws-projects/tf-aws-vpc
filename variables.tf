variable "azs_list" {
  description = "List of Availability Zones (provides a way to specify the AZ where subnets will be created)."
  default     = []
}

variable "cidr_block" {
  description = "CIDR block that the VPC should cover"
}

variable "newbits" {
  description = "Number of bits that the CIDR should be extended with when creating subnets"
  default     = 8
}

variable "enable_dns_support" {
  description = "Should DNS resolution be supported for the VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should instances launched inside the VPC be assigned DNS names"
  default     = true
}

variable "vpc_zone_name" {
  description = "The suffix domain name to use by default when resolving non Fully Qualified Domain Names"
  default     = ""
}

variable "vpc_dns_server" {
  description = "DNS Servers for the VPC"
  default     = ["AmazonProvidedDNS"]
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = "map"
}

variable "enable_nat_gateways" {
  description = "Provision nat gateways"
  default     = true
}

variable "vpc_endpoint_s3_policy" {
  description = "A policy to attach to the endpoint that controls access to the S3 service"
  default     = ""
}

variable "vpc_endpoint_dynamodb_policy" {
  description = "A policy to attach to the endpoint that controls access to the DynamoDB service"
  default     = ""
}

variable "route_propagation" {
  description = "A list of virtual gateways for propagation"
  default     = []
}
