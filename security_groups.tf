#=====================================================================
#Public access 0.0.0.0 security group allowing all traffic
#=====================================================================

resource "aws_security_group" "iops-terraform-public-sg" {
  name        = "iops-terraform-public-sg"
  description = "For public access security group, allow http https ssh inbound traffic"
  vpc_id      = aws_vpc.iops-terraformvpc.id
  #entering 

  ingress {
    description = "SSH "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #exiting
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iops-terraform-public-sg"
  }
}


#=====================================================================
#Private access security group for RDS DB
#=====================================================================
resource "aws_security_group" "iops-terraform-private-sg" {
  name        = "iops-terraform-private-sg"
  description = "Private access security group for db"
  vpc_id      = aws_vpc.iops-terraformvpc.id
  #in
  ingress {
    description     = "DB"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.iops-terraform-public-sg.id]
  }
  #out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iops-terraform-private-sg"
  }
}