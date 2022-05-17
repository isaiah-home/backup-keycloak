
terraform {
  backend "s3" {
    bucket = "terraform.ivcode.org"
    key    = "backup/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_s3_bucket" "backup" {
   bucket = "backups.ivcode.org"
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_experation" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id = "expiration"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 1
      newer_noncurrent_versions = 5
    }
  }
}
