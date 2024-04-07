provider "aws" {
  region     = "" # Change this to your desired AWS region
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "main_vpc" {
  cidr_block                       = var.main_vpc_cidr
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = element(var.azs[*], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.public_route_table
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = var.publicrtname
  }
}

resource "aws_route_table_association" "public_subnet_routeTB_association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidr)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.private_subnet_cidr, count.index)
  availability_zone       = element(var.azs[*], count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = var.nat_name
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = var.private_route_table
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.privatertname
  }
}

resource "aws_route_table_association" "private_subnet_routeTB_association" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id          = aws_vpc.main_vpc.id
  service_name    = "com.amazonaws.eu-central-1.s3"
  route_table_ids = [aws_route_table.endpoint_route.id]
  //vpc_endpoint_type = "Interface"
  //subnet_ids = aws_subnet.endpoint_subnet[*].id
  //private_dns_enabled = true

  tags = {
    Name = "vpc endpoint"
  }

}

resource "aws_route_table" "endpoint_route" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = var.endpointrtname
  }

}

resource "aws_subnet" "endpoint_subnet" {
  count                   = length(var.subnet_endpoint_cidr)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.subnet_endpoint_cidr, count.index)
  availability_zone       = element(var.azs[*], count.index)
  map_public_ip_on_launch = false
  
  tags = {
    Name = var.endpoint_subnet_name
  }

}

/*resource "aws_vpc_endpoint_subnet_association" "edp_subnet_ass" {
  vpc_endpoint_id = aws_vpc_endpoint.vpc_endpoint.id
  count = length(var.subnet_endpoint_cidr)
  subnet_id = element(aws_subnet.endpoint_subnet[*].id, count.index)
  
}*/

resource "aws_vpc_endpoint_route_table_association" "Endpoint_routeTB_association" {
  route_table_id  = aws_route_table.endpoint_route.id
  vpc_endpoint_id = aws_vpc_endpoint.vpc_endpoint.id
  

}

##################
#   S3 bucket    #
##################


resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket = "resetado-vpc-flow-logs-nu23oi2h1bh31i23"
}

resource "aws_s3_bucket_ownership_controls" "s3control" {
  bucket = aws_s3_bucket.vpc_flow_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3control]
  bucket     = aws_s3_bucket.vpc_flow_logs.id
  acl        = "private"

}

resource "aws_s3_bucket_versioning" "versioning_vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id
  versioning_configuration {
    status = "Enabled"
  }

}

##################
#   flow log     #
##################

resource "aws_flow_log" "vpc_flowlog" {
  log_destination      = aws_s3_bucket.vpc_flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = ""
  vpc_id               = aws_vpc.main_vpc.id
}