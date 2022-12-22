terraform {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
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
  # access key and secret key will be read automatically by environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = "my-bucket-ceca403b-25a1-46f7-be20-495a3619e521"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket_acl" "main_acl" {
  bucket = aws_s3_bucket.mybucket.id
  acl    = "private" # See https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.mybucket.bucket

  index_document {
    suffix = "index.html"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.mybucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "static_web_policy" {
  bucket = aws_s3_bucket.mybucket.id
  policy = templatefile(
    "${path.module}/s3_policy.json",
    {
      bucket_arn = aws_s3_bucket.mybucket.arn
    }
  )
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object
resource "aws_s3_object" "index_file" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "index.html"
  source = "${path.module}/web_resources/index.html"
  content_type = "text/html" 
  # the default content_type is binary/octet-stream so when we view it, 
  # browser will download it instead of display the file. 
  # So you have to set content_type correctly
}

resource "aws_s3_object" "main_js" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "main.js"
  source = "${path.module}/web_resources/main.js"
  content_type = "application/javascript"
}

resource "aws_s3_object" "styles_css" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "styles.css"
  source = "${path.module}/web_resources/styles.css"
  content_type = "text/css"
}

resource "aws_s3_object" "target_file_csv" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "target-file.csv"
  source = "${path.module}/web_resources/target-file.csv"
}