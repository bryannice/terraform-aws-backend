terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  access_key = var.access_key
  region     = var.region
  secret_key = var.secret_key
}

module "backend_s3_bucket" {
  bucket        = var.bucket
  enabled       = true
  force_destroy = true
  source        = "github.com/bryannice/terraform-aws-module-s3-bucket//?ref=1.1.0"
  sse_algorithm = "AES256"
}

module "backend_dynamodb" {
  attribute_name = "LockID"
  attribute_type = "S"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  name           = module.backend_s3_bucket.id
  source         = "github.com/bryannice/terraform-aws-module-dynamodb-table//?ref=1.0.0"
}