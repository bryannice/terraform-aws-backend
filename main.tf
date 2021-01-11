terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "backend_s3_bucket" {
  source        = "github.com/bryannice/terraform-aws-module-s3-bucket//?ref=1.1.0"
  bucket        = var.bucket
  enabled       = true
  sse_algorithm = "AES256"
  force_destroy = true
}

module "backend_dynamodb" {
  source         = "github.com/bryannice/terraform-aws-module-dynamodb-table//?ref=1.0.0"
  name           = module.backend_s3_bucket.id
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute_name = "LockID"
  attribute_type = "S"
}