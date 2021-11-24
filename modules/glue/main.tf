resource "aws_glue_catalog_database" "aws_glue_security_catalog_database" {
  name = var.glue_database_name
}

resource "aws_glue_crawler" "aws_glue_crawler_security_ec2_log_table_sor" {
  database_name = aws_glue_catalog_database.aws_glue_security_catalog_database.name
  schedule      = "cron(0 1 * * ? *)"
  name          = "aws_glue_crawler_security_ec2_log_table_sor"
  role          = var.aws_iam_role

  s3_target {
    path = "s3://${var.aws_s3_bucket}/"
  }

  depends_on = [
    aws_glue_catalog_database.aws_glue_security_catalog_database
  ]

}

resource "aws_glue_crawler" "aws_glue_crawler_security_ec2_log_table_spec" {
  database_name = aws_glue_catalog_database.aws_glue_security_catalog_database.name
  schedule      = "cron(0 2 * * ? *)"
  name          = "aws_glue_crawler_security_ec2_log_table_spec"
  role          = var.aws_iam_role

  s3_target {
    path = "s3://${var.spec_bucket_name}/"
  }

  depends_on = [
    aws_glue_catalog_database.aws_glue_security_catalog_database
  ]

}


resource "aws_glue_security_configuration" "glueSecuritySettings" {
  name = "glueSecuritySettings"

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "DISABLED"
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "DISABLED"
    }

    s3_encryption {
      kms_key_arn        = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
      s3_encryption_mode = "SSE-KMS"
    }
  }
}

#https://medium.com/analytics-vidhya/add-new-partitions-in-aws-glue-data-catalog-from-aws-glue-job-79b0442b17af
#https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-points.html