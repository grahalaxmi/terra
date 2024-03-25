resource "aws_vpc" "test" {
    provider = aws.central
  cidr_block = var.cidr_block2
  enable_dns_hostnames=true
  tags = {
    "Name" = var.vpc2_name
  }
}

resource "aws_internet_gateway" "testigw" {
    provider = aws.central
  vpc_id = aws_vpc.test.id
  tags = {
        "Name" = "${var.vpc2_name}-igw2"
    }
}

resource "aws_subnet" "testpublicsubnet" {
    provider = aws.central
  vpc_id = aws_vpc.test.id
  count = 2
  cidr_block = element(var.cidr_block2_subnet,count.index+1)
  availability_zone = element(var.avz2,count.index+1)
  tags = {
    "Name" = "${var.vpc1_name}-publicsubnet2${count.index+1}"
  }
}
resource "aws_route_table" "testrt" {
    provider = aws.central
  vpc_id = aws_vpc.test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testigw.id
  }
  tags = {
        "Name" = "${var.vpc2_name}-rt2"
    }
}

resource "aws_route_table_association" "testrtassociation" {
    provider = aws.central
  count=2
  subnet_id = element(aws_subnet.testpublicsubnet.*.id,count.index+1)
  route_table_id = aws_route_table.testrt.id
}
 resource "aws_route" "accepter-communication" {
     provider = aws.central
   route_table_id = aws_route_table.testrt.id
   vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
   destination_cidr_block = var.cidr_block1
 }


resource "aws_security_group" "testsg" {
    provider = aws.central
  vpc_id = aws_vpc.test.id
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
    "Name" = "${var.vpc2_name}-sg2"
  }
}

resource "aws_instance" "testserver" {
    provider = aws.central
  ami = "ami-019f9b3318b7155c5"
  instance_type = "t2.micro"
  key_name = "nag"
  vpc_security_group_ids = [aws_security_group.testsg.id]
  subnet_id = aws_subnet.testpublicsubnet[1].id
  associate_public_ip_address=true
  tags = {
    "Name" = "${var.vpc2_name}-server2"
  }
}