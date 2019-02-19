data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags                 = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-vpc"))}"
}

#PUBLIC SUBNETS
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags   = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-igw"))}"
}

resource "aws_subnet" "public" {
  count             = "${length(var.azs_list)}"
  availability_zone = "${var.azs_list[count.index]}"
  cidr_block        = "${cidrsubnet(var.cidr_block, var.newbits, count.index)}"
  vpc_id            = "${aws_vpc.main.id}"
  tags              = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-public-${element(split(",", "${var.azs_list[count.index]}"), count.index)}"))}"
}

resource "aws_default_route_table" "public" {
  default_route_table_id = "${aws_vpc.main.main_route_table_id}"
  propagating_vgws       = ["${var.route_propagation}"]
  tags                   = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-public"))}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.azs_list)}"
  route_table_id = "${aws_vpc.main.main_route_table_id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_route" "public" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

#PRIVATE SUBNETS
resource "aws_eip" "nat_eip" {
  count      = "${var.enable_nat_gateways ? length(var.azs_list) : 0}"
  vpc        = true
  depends_on = ["aws_internet_gateway.main"]
  tags       = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-private-${element(split(",", "${var.azs_list[count.index]}"), count.index)}"))}"
}

resource "aws_nat_gateway" "nat" {
  count         = "${var.enable_nat_gateways ? length(var.azs_list) : 0}"
  allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.main", "aws_eip.nat_eip"]
  tags          = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-private-${element(split(",", "${var.azs_list[count.index]}"), count.index)}"))}"
}

resource "aws_subnet" "private" {
  count             = "${length(var.azs_list)}"
  availability_zone = "${var.azs_list[count.index]}"
  cidr_block        = "${cidrsubnet(var.cidr_block, var.newbits, count.index + length(var.azs_list))}"
  vpc_id            = "${aws_vpc.main.id}"
  tags              = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-private-${element(split(",", "${var.azs_list[count.index]}"), count.index)}"))}"
}

resource "aws_route_table" "private" {
  count  = "${length(var.azs_list)}"
  vpc_id = "${aws_vpc.main.id}"
  tags   = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-private-${element(split(",", "${var.azs_list[count.index]}"), count.index)}"))}"
}

resource "aws_route" "internet_route_private" {
  count                  = "${var.enable_nat_gateways ? length(var.azs_list) : 0}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.azs_list)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "${var.vpc_zone_name != "" ? var.vpc_zone_name : "${data.aws_region.current.name}.compute.internal"}"
  domain_name_servers = ["${var.vpc_dns_server}"]
  tags                = "${merge(var.tags,map("Name", "${var.tags["prefix"]}-dhcp-options-set"))}"
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = "${aws_vpc.main.id}"
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  policy          = "${var.vpc_endpoint_s3_policy}"
  route_table_ids = ["${concat("${aws_route_table.private.*.id}", "${aws_default_route_table.public.*.id}")}"]
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = "${aws_vpc.main.id}"
  service_name    = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  policy          = "${var.vpc_endpoint_dynamodb_policy}"
  route_table_ids = ["${concat("${aws_route_table.private.*.id}", "${aws_default_route_table.public.*.id}")}"]
}
