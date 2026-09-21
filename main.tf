terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# INTENTIONALLY INSECURE: for Checkov demo only
resource "aws_s3_bucket" "demo" {
  bucket = "iac-lab-meda-2026"
}

resource "aws_s3_bucket_ownership_controls" "demo" {
  bucket = aws_s3_bucket.demo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "demo" {
  depends_on = [
    aws_s3_bucket_ownership_controls.demo,
    aws_s3_bucket_public_access_block.demo,
  ]
  bucket = aws_s3_bucket.demo.id
  acl    = "private"
}

resource "aws_security_group" "demo" {
  name        = "iac-lab-public-ssh"

  ingress {
    description = "Intentionally open SSH for scanner demo"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
