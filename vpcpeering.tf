resource "aws_vpc_peering_connection" "requester" {
    peer_owner_id = "375839634801"
    vpc_id = aws_vpc.dev.id
    peer_vpc_id = aws_vpc.test.id
    auto_accept = false
    peer_region = "us-east-2"
    tags = {
        "Name" = "requester"
    }
  
}
resource "aws_vpc_peering_connection_accepter" "accepter" {
vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
provider = aws.central
auto_accept = true
tags = {
    "Name" = "accepter"
    }
}
