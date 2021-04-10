/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}
/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.*.id[0]}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}
/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
#  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${var.public_subnets_cidr}"
  availability_zone       = "${var.availability_zones}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-${var.availability_zones}-public-subnet"
    Environment = "${var.environment}"
  }
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
#  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${var.private_subnets_cidr}"
  availability_zone       = "${var.availability_zones}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${var.availability_zones}-private-subnet"
    Environment = "${var.environment}"
  }
}
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}
/* Route table associations */
resource "aws_route_table_association" "public" {
#  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
#  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private.id}"
}
/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}

/*==== Webserver Security Group ======*/
resource "aws_security_group" "webserver" {
  name        = "${var.environment}-webserver-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    description     = "ssh"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}

/*==== DB Security Group ======*/
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    description     = "ssh"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "mysql"
    cidr_blocks     = ["10.0.0.0/24"]
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}

/*==== Webserver EC2 Instance ======*/
resource "aws_instance" "webserver" {
  ami                      = data.aws_ami.amazon_linux.id
  count                    = length(var.webserver_ips)
  instance_type            = var.webserver_instance_type
  key_name                 = var.key_name
  ebs_optimized            = var.ebs_optimized
  vpc_security_group_ids   = [aws_security_group.webserver.id]
  subnet_id                = "${aws_subnet.public_subnet.*.id[0]}"
  private_ip               = var.webserver_ips
  tags  = {
    Name                 = "webserver"
  }
}

/*==== Webserver EC2 Instance ======*/
resource "aws_instance" "db" {
  ami                      = data.aws_ami.amazon_linux.id
  count                    = length(var.db_ips)
  instance_type            = var.db_instance_type
  key_name                 = var.key_name
  ebs_optimized            = var.ebs_optimized
  vpc_security_group_ids   = [aws_security_group.db.id]
  subnet_id                = "${aws_subnet.private_subnet.*.id[0]}"
  private_ip               = var.db_ips
  tags = {
    Name                 = "db-server"
  }
}

