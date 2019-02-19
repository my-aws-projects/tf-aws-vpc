# tf-aws-vpc

## Overview

Terraform AWS module for creating VPCs with Public and Private subnets backed by NAT Gateway instances.
Also a VPC endpoint to S3 is created for public and private routes.

## Usage

The following example would create:

* 1 Public subnet in 2 AZ with an Internet Gateway
    - AZ1 (us-east-1d): 10.100.2.0/24
    - AZ2 (us-east-1e): 10.100.3.0/24
* 1 Private subnet in 2 AZ with a NAT Gateway on each AZ
    - AZ1 (us-east-1d): 10.100.0.0/24
    - AZ2 (us-east-1e): 10.100.1.0/24

```hcl
variable "vpc" {
  default = {
    "cidr_block" = "10.100.0.0/16"
    "newbits"    = "8"
  }
}

variable "vpc_azs_list" {
  default = [
    "us-east-1d",
    "us-east-1e"
  ]
}

module "vpc" {
  source = "../../modules/tf-aws-vpc"

  cidr_block = "${var.vpc["cidr_block"]}"
  newbits    = "${var.vpc["newbits"]}"
  azs_list   = "${var.vpc_azs_list}"

  tags = {
    prefix = "${var.env["prefix"]}"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| azs_list | List of Availability Zones (provides a way to specify the AZ where subnets will be created). | string | `<list>` | no |
| cidr_block | CIDR block that the VPC should cover | string | - | yes |
| enable_dns_hostnames | Should instances launched inside the VPC be assigned DNS names | string | `true` | no |
| enable_dns_support | Should DNS resolution be supported for the VPC | string | `true` | no |
| enable_nat_gateways | Provision nat gateways | string | `true` | no |
| newbits | Number of bits that the CIDR should be extended with when creating subnets | string | `8` | no |
| tags | A mapping of tags to assign to the resource | map | - | yes |
| vpc_dns_server | DNS Servers for the VPC | list | [`AmazonProvidedDNS`] | no |
| vpc_endpoint_dynamodb_policy | A policy to attach to the endpoint that controls access to the DynamoDB service | string | `` | no |
| vpc_endpoint_s3_policy | A policy to attach to the endpoint that controls access to the S3 service | string | `` | no |
| vpc_zone_name | The suffix domain name to use by default when resolving non Fully Qualified Domain Names | string | `` | no |
| route_propagation | A list of virtual gateways for propagation | list | - | no |

## Outputs

| Name | Description |
|------|-------------|
| availability_zones | List of the AZs that will be used |
| private_route_tables_ids | Identifier of the route tables used by all the private subnets |
| private_subnet_ids | List of private subnets identifiers |
| private_subnets_cidr_blocks | List of private subnets CIDR blocks |
| public_nat_gateways | List of Elastic IP addresses associated to the NAT gateways |
| public_route_table_id | Route tables |
| public_subnet_ids | Subnets |
| public_subnets_cidr_blocks | CIDRs |
| vpc_cidr_block | CIDR block that the VPC covers |
| vpc_id | Identifier of the VPC created |
