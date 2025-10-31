variable "vpc_cidr" { 
    type = string 
    default = "10.21.0.0/16" 
    }

variable "subnet_cidr" { 
    type = string 
    default = "10.21.1.0/24" 
    }

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "presentation-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = { Name = "presentation-subnet" }
}

resource "aws_internet_gateway" "gw" { vpc_id = aws_vpc.this.id }

resource "aws_route_table" "public" { vpc_id = aws_vpc.this.id }

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" { value = aws_vpc.this.id }
output "subnet_id" { value = aws_subnet.public.id }