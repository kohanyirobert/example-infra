data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnets = {
    "primary" = {
      public_cidr_block  = "10.0.1.0/24"
      private_cidr_block = "10.0.10.0/24"
      availability_zone  = data.aws_availability_zones.available.names[0]
    },
    "secondary" = {
      public_cidr_block  = "10.0.2.0/24"
      private_cidr_block = "10.0.20.0/24"
      availability_zone  = data.aws_availability_zones.available.names[1]
    },
    "tetriary" = {
      public_cidr_block  = "10.0.3.0/24"
      private_cidr_block = "10.0.30.0/24"
      availability_zone  = data.aws_availability_zones.available.names[2]
    }
  }
}

resource "aws_subnet" "public" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.public_cidr_block

  tags = {
    Name    = "${var.project}-public"
    Project = var.project
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.private_cidr_block

  tags = {
    Name    = "${var.project}-private"
    Project = var.project
  }
}
