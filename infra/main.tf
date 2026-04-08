terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

variable "aws_region" { default = "us-east-1" }
variable "db_user" {
  type      = string
  sensitive = true
}
variable "db_pass" {
  type      = string
  sensitive = true
}
variable "env" { default = "dev" }
variable "qwen_key" { sensitive = true }
variable "deepseek_key" { sensitive = true }

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_security_group" "db_sg" {
  name_prefix = "geo-db-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_db_instance" "geo_db" {
  engine                  = "postgres"
  engine_version          = "16.3"
  instance_class          = "db.r6g.large"
  db_name                 = "neuralis_geo"
  username                = var.db_user
  password                = var.db_pass
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  parameter_group_name    = "default.postgres16"
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = 7
  skip_final_snapshot     = true
}

resource "aws_db_subnet_group" "main" {
  name       = "geo-db-subnets-${var.env}"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_ecs_cluster" "main" {
  name = "neuralis-geo-cluster-${var.env}"
}

resource "aws_s3_bucket" "audit_exports" {
  bucket = "neuralis-geo-exports-${var.env}"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.audit_exports.id
  versioning_configuration { status = "Enabled" }
}

output "db_endpoint" { value = aws_db_instance.geo_db.endpoint }
output "ecs_cluster_arn" { value = aws_ecs_cluster.main.arn }
