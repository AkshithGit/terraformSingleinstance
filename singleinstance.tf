provider "aws" {
  region = "us-east-1"
  access_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }
#create a custom vpc
  resource "aws_vpc" "renewed-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "renewed-vpc"
  }
}
#create custom subnet
resource "aws_subnet" "renewed-sub" {
  vpc_id     = aws_vpc.renewed-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sub-1"
  }
}
#create internet gateway
resource "aws_internet_gateway" "renewed-igw" {
  vpc_id = aws_vpc.renewed-vpc.id

  tags = {
    Name = "renewed-igw"
  }
}
#creating custom route table
resource "aws_route_table" "renewed-rt" {
  vpc_id = aws_vpc.renewed-vpc.id

  tags = {
    Name = "renewed-rt"
  }
}
#create route to igw
resource "aws_route" "renewed-route" {
  route_table_id            = aws_route_table.renewed-rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.renewed-igw.id
}
#create route association to subnet
resource "aws_route_table_association" "renewed-rt-assos" {
  subnet_id      = aws_subnet.renewed-sub.id
  route_table_id = aws_route_table.renewed-rt.id
}
#create security group 
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.renewed-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}
#create a key-pair
resource "aws_key_pair" "renewed-key" {
  key_name   = "renewed-key"
  public_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

#create ec2 machine
resource "aws_instance" "renewed-instance" {
  ami = "ami-00ddb0e5626798373"
  availability_zone = "us-east-1b"
  instance_type = "t2.micro"
  key_name = "renewed-key"
  subnet_id = aws_subnet.renewed-sub.id
  vpc_security_group_ids = [ aws_security_group.allow_all.id ]
  associate_public_ip_address = true
  tags ={
      Name = "renewed-instance"
  }
}
output "instance_ips" {
value = "${aws_instance.renewed-instance.*.public_ip}"
}
output "ebs-id" {
  value = "${aws_instance.renewed-instance.ebs_block_device.*.volume_id}"
}
