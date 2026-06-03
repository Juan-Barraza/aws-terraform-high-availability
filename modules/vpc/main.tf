resource "aws_vpc" "vpc_virginia" {
  cidr_block = var.virginia_vpc.cidr

  tags = {
    "Name" = "vpc_virginia"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.vpc_virginia.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.zone[count.index]

  tags = {
    "Name" = "public_subnet_${count.index + 1}"
  }
}



resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc_virginia.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.zone[count.index]
  tags = {
    "Name" = "private_subnet_${count.index + 1}"
  }
}


resource "aws_internet_gateway" "virginia_igw" {
  vpc_id = aws_vpc.vpc_virginia.id

  tags = {
    "Name" = "igw_vpc_virginia"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_virginia.id

  route {
    cidr_block = var.route_table_cidr
    gateway_id = aws_internet_gateway.virginia_igw.id
  }

  tags =  {
    "Name" = "public_route_table"
  }
}

resource "aws_route_table_association" "assc_public_subnet" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_eip" "nat_eip" {
  tags = {
    "Name" = "eip_nat_virginia"
  }
}


resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet[0].id

  tags = {
    "Name" = "gw NAT"
  }

  depends_on = [ aws_internet_gateway.virginia_igw ]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_virginia.id

  route {
    cidr_block = var.route_table_cidr
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    "Name" = "private_route_table"
  }
}

resource "aws_route_table_association" "assc_private_subnet_nat" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}