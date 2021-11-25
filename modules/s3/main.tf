resource "aws_s3_bucket" "dl_bucket" {
  bucket        = var.bucket_name
  acl           = var.acl
  force_destroy = var.force_destroy
  policy        = var.policy

  versioning {
    enabled    = var.versioning_enabled
    mfa_delete = var.versioning_mfa_delete_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_arn
      }
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {

  dynamic "statement" {
    for_each = var.allow_encrypted_uploads_only ? [1] : []

    content {
      sid       = "DenyIncorrectEncryptionHeader"
      effect    = "Deny"
      actions   = ["s3:PutObject"]
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.dl_bucket.*.id)}/*"]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      condition {
        test     = "StringNotEquals"
        values   = [var.sse_algorithm]
        variable = "s3:x-amz-server-side-encryption"
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_encrypted_uploads_only ? [1] : []

    content {
      sid       = "DenyUnEncryptedObjectUploads"
      effect    = "Deny"
      actions   = ["s3:PutObject"]
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.dl_bucket.*.id)}/*"]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      condition {
        test     = "Null"
        values   = ["true"]
        variable = "s3:x-amz-server-side-encryption"
      }
    }
  }

  dynamic "statement" {
    for_each = var.allow_ssl_requests_only ? [1] : []

    content {
      sid     = "ForceSSLOnlyAccess"
      effect  = "Deny"
      actions = ["s3:*"]
      resources = [
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.dl_bucket.*.id)}",
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.dl_bucket.*.id)}/*"
      ]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      condition {
        test     = "Bool"
        values   = ["false"]
        variable = "aws:SecureTransport"
      }
    }
  }

  dynamic "statement" {

    for_each = var.allow_ssl_requests_only ? [1] : []

    content {
      sid     = "AllowWriteObject"
      effect  = "Allow"
      actions = ["s3:ListBucket", "s3:PutObject"]
      resources = [
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.dl_bucket.*.id)}",
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.dl_bucket.*.id)}/*"
      ]

      principals {
        identifiers = ["*"]
        type        = "*"
      }

      dynamic "condition" {
        for_each = var.accounts_allowed
        content {
          test     = "ArnLike"
          values   = ["arn:aws:iam:*:${condition.value}:*"]
          variable = "aws:PrincipalArn"
        }
      }
    }
  }

}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "aggregated_policy" {
  source_json   = var.policy
  override_json = join("", data.aws_iam_policy_document.bucket_policy.*.json)
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.dl_bucket.id
  policy = join("", data.aws_iam_policy_document.aggregated_policy.*.json)
  depends_on = [
    aws_s3_bucket.dl_bucket,
    data.aws_iam_policy_document.aggregated_policy
  ]
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = join("", aws_s3_bucket.dl_bucket.*.id)

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  depends_on = [
    aws_s3_bucket.dl_bucket,
    aws_s3_bucket_policy.default
  ]
}
