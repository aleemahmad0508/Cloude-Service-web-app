
# ==========================================
# RDS DB SUBNET GROUP
# ==========================================

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "${var.project_name}-rds-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

# ==========================================
# RDS POSTGRESQL DATABASE
# ==========================================

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "17"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false

  skip_final_snapshot = true

  deletion_protection = false

  tags = {
    Name    = "${var.project_name}-postgres"
    Project = var.project_name
  }
}
