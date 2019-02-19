output "availability_zones" {
  description = "List of the AZs that will be used"
  value       = [ "${var.azs_list}" ]
}

output "vpc_id" {
  description = "Identifier of the VPC created"
  value       = "${aws_vpc.main.id}"
}

output "vpc_cidr_block" {
  description = "CIDR block that the VPC covers"
  value       = "${aws_vpc.main.cidr_block}"
}

output "public_nat_gateways" {
  description = "List of Elastic IP addresses associated to the NAT gateways"
  value       = [ "${aws_eip.nat_eip.*.public_ip}" ]
}

#Subnets
output "public_subnet_ids" {
  description = "List of public subnets identifiers"
  value       = [ "${aws_subnet.public.*.id}" ]
}

output "private_subnet_ids" {
  description = "List of private subnets identifiers"
  value       = [ "${aws_subnet.private.*.id}" ]
}

#CIDRs
output "public_subnets_cidr_blocks" {
  description = "List of public subnets CIDR blocks"
  value       = [ "${aws_subnet.public.*.cidr_block}" ]
}

output "private_subnets_cidr_blocks" {
  description = "List of private subnets CIDR blocks"
  value       = [ "${aws_subnet.private.*.cidr_block}" ]
}

#Route tables
output "public_route_table_id" {
  description = "Identifier of the route table used by all the public subnets"
  value       = "${aws_vpc.main.main_route_table_id}"
}

output "private_route_tables_ids" {
  description = "Identifier of the route tables used by all the private subnets"
  value       = [ "${aws_route_table.private.*.id}" ]
}
