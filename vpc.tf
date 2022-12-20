
#=====================================================================
#Creating VPC - terr_vpc only local terraform name
#=====================================================================

resource "aws_vpc" "iops-terraformvpc" {
  cidr_block = "10.0.0.0/16" #65,536

  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "iops-terraformvpc"
  }
}


#Subnets (3 availability zone)
#Public 
resource "aws_subnet" "iops-PublicSubnet-A" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = "10.0.11.0/24" #256
  availability_zone = "eu-central-1a"
  #- (Optional) Specify true to indicate that instances 
  #launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  tags = {
    Name = "iops-PublicSubnet-A"
  }
}

resource "aws_subnet" "iops-PublicSubnet-B" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "eu-central-1b"
  #- (Optional) Specify true to indicate that instances 
  #launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  tags = {
    Name = "iops-PublicSubnet-B"
  }
}

#Private for RDS
resource "aws_subnet" "iops-PrivateSubnet-A" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = "10.0.12.0/24" #256
  availability_zone = "eu-central-1a"

  tags = {
    Name = "iops-PrivateSubnet-A"
  }
}

#Private for RDS
resource "aws_subnet" "iops-PrivateSubnet-B" {
  vpc_id            = aws_vpc.iops-terraformvpc.id
  cidr_block        = "10.0.22.0/24" #256
  availability_zone = "eu-central-1b"

  tags = {
    Name = "iops-PrivateSubnet-B"
  }
}



#Internet gateway 
resource "aws_internet_gateway" "iops-terraform-ig" {
  vpc_id = aws_vpc.iops-terraformvpc.id
  tags = {
    Name = "iops-terraform-ig"
  }
}

#Route table to route trafic from our subnet to internet gateway
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
#The destination for the route is 0.0.0.0/0, which represents all IPv4 addresses. 
#The target is the internet gateway that's attached to VPC.
resource "aws_route_table" "iops_terraform_rtb_pub" {
  vpc_id = aws_vpc.iops-terraformvpc.id

  #igw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iops-terraform-ig.id
  }

  #local target
  #The default route, mapping the VPC's CIDR block to "local", 
  #is created implicitly and cannot be specified.

  tags = {
    Name = "iops-terraform-rtb-pub"
  }
}

resource "aws_route_table" "iops_terraform_rtb_private" {
  vpc_id = aws_vpc.iops-terraformvpc.id

  tags = {
    Name = "iops-terraform-rtb-private"
  }
}

#==============================================================
#Route table association
#Asociation b/w a route table and a subnet
#Provides a resource to create an association between a route 
#table and a subnet or a route table and an internet gateway or
# virtual private gateway.

#===============================================================
#public a
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.iops-PublicSubnet-A.id
  route_table_id = aws_route_table.iops_terraform_rtb_pub.id
}
#public b
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.iops-PublicSubnet-B.id
  route_table_id = aws_route_table.iops_terraform_rtb_pub.id
}

#private a
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.iops-PrivateSubnet-A.id
  route_table_id = aws_route_table.iops_terraform_rtb_private.id
}

#private b
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.iops-PrivateSubnet-B.id
  route_table_id = aws_route_table.iops_terraform_rtb_private.id
}



# #aws_main_route_table_association
# resource "aws_default_route_table" "terr_public_assosiation" {
#   vpc_id         = aws_vpc.terr_vpc.id
#   default_route_table_id = aws_route_table.terr_rtb_public.id
# }

# #aws_main_route_table_association
# resource "aws_default_route_table" "terr_private_assosiation" {
#   vpc_id         = aws_vpc.terr_vpc.id
#   default_route_table_id = aws_route_table.terr_rtb_private.id  #route_table_id instead if aws_main_route_table_association is used
# }


