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

resource "aws_s3_bucket" "demo" {
  bucket = "iac-lab-meda-2026"
  #checkov:skip=CKV_AWS_144:Cross-region replication not needed for a demo bucket
  #checkov:skip=CKV2_AWS_61:No lifecycle requirements for an empty demo bucket
  #checkov:skip=CKV2_AWS_62:No event consumers in this demo
  #checkov:skip=CKV_AWS_18:Access logging needs a separate log bucket, out of scope
}

resource "aws_s3_bucket_ownership_controls" "demo" {
  bucket = aws_s3_bucket.demo.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_security_group" "demo" {
  name        = "iac-lab-restricted-ssh"
  description = "SSH restricted to a single admin CIDR"

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.10/32"]
  }
}
resource "aws_kms_key" "demo" {
  description         = "Key for the demo S3 bucket"
  enable_key_rotation = true
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.demo.arn
    }
  }
}
