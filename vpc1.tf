resource "aws_vpc" "dev" {
  cidr_block = var.cidr_block1
  enable_dns_hostnames=true
  tags = {
    "Name" = var.vpc1_name
  }
}

resource "aws_internet_gateway" "devigw" {
  vpc_id = aws_vpc.dev.id
  tags = {
        "Name" = "${var.vpc1_name}-igw1"
    }
}

resource "aws_subnet" "devpublicsubnet" {
  vpc_id = aws_vpc.dev.id
  count = 2
  cidr_block = element(var.cidr_block1_subnet,count.index+1)
  availability_zone = element(var.avz1,count.index+1)
  tags = {
    "Name" = "${var.vpc1_name}-publicsubnet1${count.index+1}"
  }
}

resource "aws_route_table" "devrt" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devigw.id
  }
  tags = {
        "Name" = "${var.vpc1_name}-rt1"
    }
}

resource "aws_route_table_association" "devrtassociation" {
  count=2
  subnet_id = element(aws_subnet.devpublicsubnet.*.id,count.index+1)
  route_table_id = aws_route_table.devrt.id
}

 resource "aws_route" "requester-communication" {
 route_table_id = aws_route_table.devrt.id
 vpc_peering_connection_id=aws_vpc_peering_connection.requester.id
 destination_cidr_block = var.cidr_block2
 }



resource "aws_security_group" "devsg" {
  vpc_id = aws_vpc.dev.id
  description = "sg creation"
  ingress {
    to_port = 0
    from_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    to_port = 0
    from_port = 0
    protocol = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    "Name" = "${var.vpc1_name}-sg1"
  }
}

resource "aws_instance" "devserver" {
  ami = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  key_name = "graha"
  vpc_security_group_ids = [aws_security_group.devsg.id]
  subnet_id = aws_subnet.devpublicsubnet[1].id
  associate_public_ip_address=true
  tags = {
    "Name" = "${var.vpc1_name}-server1"
  }
}