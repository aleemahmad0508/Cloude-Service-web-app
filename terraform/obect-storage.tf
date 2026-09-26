# ==========================================
# S3 BUCKET FOR FILE UPLOADS
# ==========================================

resource "aws_s3_bucket" "cloud_notes" {
  bucket = "${var.project_name}-files-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "${var.project_name}-s3"
    Project = var.project_name
  }
}

# ==========================================
# S3 BUCKET VERSIONING
# ==========================================

resource "aws_s3_bucket_versioning" "cloud_notes" {
  bucket = aws_s3_bucket.cloud_notes.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ==========================================
# S3 SERVER-SIDE ENCRYPTION
# ==========================================

resource "aws_s3_bucket_server_side_encryption_configuration" "cloud_notes" {
  bucket = aws_s3_bucket.cloud_notes.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==========================================
# BLOCK PUBLIC ACCESS
# ==========================================

resource "aws_s3_bucket_public_access_block" "cloud_notes" {
  bucket = aws_s3_bucket.cloud_notes.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}