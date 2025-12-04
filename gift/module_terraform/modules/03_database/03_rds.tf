# ================================================
# RDS Cluster
# ================================================
resource "aws_rds_cluster" "this" {
  availability_zones                  = ["ap-southeast-2a", "ap-southeast-2c"]
  cluster_identifier                  = "sample-dev-rds"
  cluster_members                     = ["sample-dev-rds-dbinstance-a"]
  copy_tags_to_snapshot               = true
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.rds_cluster_pg.name
  db_subnet_group_name                = aws_db_subnet_group.this.name
  deletion_protection                 = false
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  engine                              = "aurora-mysql"
  engine_lifecycle_support            = "open-source-rds-extended-support"
  engine_mode                         = "provisioned"
  engine_version                      = "5.7.mysql_aurora.2.11.5"
  master_username                     = "testuser"
  master_password                     = "testpass"
  port                                = 3306
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  vpc_security_group_ids              = [var.security_group["rds_id"]]
  depends_on = [
    aws_db_subnet_group.this,
    aws_rds_cluster_parameter_group.rds_cluster_pg
  ]
  lifecycle {
    ignore_changes = [availability_zones]
  }
}

# ================================================
# RDS Cluster Instance
# ================================================
resource "aws_rds_cluster_instance" "this" {
  auto_minor_version_upgrade = true
  availability_zone          = "ap-southeast-2a"
  ca_cert_identifier         = "rds-ca-rsa2048-g1"
  cluster_identifier         = "sample-dev-rds"
  db_parameter_group_name    = aws_db_parameter_group.rds_pg.name
  db_subnet_group_name       = aws_db_subnet_group.this.name
  engine                     = "aurora-mysql"
  engine_version             = "5.7.mysql_aurora.2.11.5"
  identifier                 = "sample-dev-rds-dbinstance-a"
  instance_class             = "db.t3.small"
  promotion_tier             = 1
  publicly_accessible        = false

  depends_on = [
    aws_rds_cluster.this,
    aws_db_parameter_group.rds_pg
  ]
}

# ================================================
# RDS Subnet Group
# ================================================
resource "aws_db_subnet_group" "this" {
  description = "sample-dev-rds-subgrp"
  name        = "sample-dev-rds-subgrp"
  subnet_ids  = [var.subnet["private_a_id"], var.subnet["private_c_id"]]
}

# ================================================
# RDS Paramter Group
# ================================================
resource "aws_db_parameter_group" "rds_pg" {
  description  = "sample-dev-rds-pg"
  family       = "aurora-mysql5.7"
  name         = "sample-dev-rds-pg"
  skip_destroy = false
}

resource "aws_rds_cluster_parameter_group" "rds_cluster_pg" {
  description = "sample-dev-rds-cluster-pg"
  family      = "aurora-mysql5.7"
  name        = "sample-dev-rds-cluster-pg"
}
