resource "aws_s3_bucket" "glue_bucket_assets" {
  bucket        = "aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-2"
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
        kms_master_key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
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
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.glue_bucket_assets.*.id)}/*"]

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
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.glue_bucket_assets.*.id)}/*"]

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
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.glue_bucket_assets.*.id)}",
        "arn:${data.aws_partition.current.partition}:s3:::${join("", aws_s3_bucket.glue_bucket_assets.*.id)}/*"
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

}

data "aws_iam_policy_document" "aggregated_policy" {
  source_json   = var.policy
  override_json = join("", data.aws_iam_policy_document.bucket_policy.*.json)
}


resource "aws_s3_bucket_policy" "default" {
  bucket = join("", aws_s3_bucket.glue_bucket_assets.*.id)
  policy = join("", data.aws_iam_policy_document.aggregated_policy.*.json)
}

resource "aws_s3_bucket_public_access_block" "default" {

  bucket = join("", aws_s3_bucket.glue_bucket_assets.*.id)

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  depends_on = [
    aws_s3_bucket_policy.default
  ]

}

data "template_file" "json_template_glue_python" {

  template = "${path.module}/scripts/json-to-parquet.py.tpl"

  vars = {
    sor_bucket_name  = var.aws_s3_bucket
    spec_bucket_name = var.spec_bucket_name
  }
}


resource "aws_s3_bucket_object" "json_job_script" {
  bucket     = aws_s3_bucket.glue_bucket_assets.id
  key        = "/scripts/json-to-parquet.py"
  content    = data.template_file.json_template_glue_python.rendered
  kms_key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
  depends_on = [
    data.template_file.json_template_glue_python
  ]
}

data "template_file" "xml_template_glue_python" {
  template = "${path.module}/scripts/xml-to-parquet.py.tpl"

  vars = {
    sor_bucket_name  = var.aws_s3_bucket
    spec_bucket_name = var.spec_bucket_name
  }
}

resource "aws_s3_bucket_object" "xml_job_script" {
  bucket     = aws_s3_bucket.glue_bucket_assets.id
  key        = "/scripts/xml-to-parquet.py"
  content    = data.template_file.xml_template_glue_python.rendered
  kms_key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"

  depends_on = [
    data.template_file.xml_template_glue_python
  ]
}




