#=====================================================================
#RDS instance resource.

#MySQL
# Constraints to the amount of storage for each storage type are the following:
# General Purpose (SSD) storage (gp2, gp3): Must be an integer from 20 to 65536.
# Provisioned IOPS storage (io1): Must be an integer from 100 to 65536.
# Magnetic storage (standard): Must be an integer from 5 to 3072.


#=====================================================================
resource "aws_db_instance" "iops-terraform" {
  identifier            = "iops-terraform-db"
  instance_class        = "db.t2.micro"
  allocated_storage     = 10
  max_allocated_storage = 0 #to disable Storage Autoscaling.
  engine                = "mysql"
  engine_version        = "8.0.28"

  #credentials
  username = var.db_username
  password = var.db_password

  #db conf
  db_name              = var.db_name
  parameter_group_name = "default.mysql8.0"

  #network conf
  db_subnet_group_name   = aws_db_subnet_group.terr_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.iops-terraform-private-sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  backup_retention_period    = 0
  auto_minor_version_upgrade = false

  apply_immediately = true

}


#=====================================================================
#RDS Subnet group.
# designates a collection of subnets that your RDS instance can be
# provisioned in. This subnet group uses the subnets created by the
# VPC module.
#=====================================================================

resource "aws_db_subnet_group" "terr_db_subnet_group" {
  name       = "terr-db-subnet-group"
  subnet_ids = [aws_subnet.iops-PrivateSubnet-A.id, aws_subnet.iops-PrivateSubnet-B.id]

  tags = {
    Name = "terr-db-subnet-group"
  }
}