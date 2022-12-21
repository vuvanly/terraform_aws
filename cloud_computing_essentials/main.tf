terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-1"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "my-bucket-ceca403b-25a1-46f7-be20-495a3619e521"
  #policy = file("s3_policy.json")

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }

  # website {
  #   index_document = "index.html"
  # }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.mybucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "main_acl" {
  bucket = aws_s3_bucket.mybucket.id
  acl    = "private"
}