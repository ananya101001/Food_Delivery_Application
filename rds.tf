# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id
  

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
   
    security_groups = [aws_security_group.allow_ssh_http_1.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

# Create a subnet group for the RDS instance
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "RDS subnet group"
  }
}

# Create the RDS instance
resource "aws_db_instance" "food_delivery_db" {
  identifier           = "food-delivery-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  db_name              = "fooddeliverydb"
  username             = "ananya"
  password             = "UberSecretPassword"
  parameter_group_name = "default.mysql8.0"

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "FoodDeliveryRDSInstance"
  }
}

# Output the RDS instance endpoint
output "rds_endpoint" {
  value = aws_db_instance.food_delivery_db.endpoint
}