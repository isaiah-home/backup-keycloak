
terraform {
  backend "s3" {
    bucket = "terraform.ivcode.org"
    key    = "backup/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "backup" {
   bucket = "test.ivcode.org"
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_experation" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id = "keycloak-expiration"
    status = "Enabled"
    filter {
      prefix = "keycloak/"
    }
    noncurrent_version_expiration {
      noncurrent_days = 1
      newer_noncurrent_versions = 5
    }
  }
  rule {
    id = "wikijs-expiration"
    status = "Enabled"
    filter {
      prefix = "wikijs/"
    }
    noncurrent_version_expiration {
      noncurrent_days = 1
      newer_noncurrent_versions = 5
    }
  }
}

