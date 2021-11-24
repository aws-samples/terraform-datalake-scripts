resource "aws_cloudwatch_log_group" "json_to_parquet_logs" {
  name              = "json_to_parquet_logs_json"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "xml_to_parquet_logs" {
  name              = "xml_to_parquet_logs_json"
  retention_in_days = 14
}

resource "aws_glue_job" "json_to_parquet" {
  name     = "json_to_parquet"
  role_arn = var.aws_iam_role

  command {
    script_location = "s3://${aws_s3_bucket.glue_bucket_assets.bucket}/scripts/json-to-parquet.py"
    python_version  = 3
  }

  glue_version      = "2.0"
  max_retries       = 0
  worker_type       = "G.1X"
  number_of_workers = 10

  security_configuration = aws_glue_security_configuration.glueSecuritySettings.id

  default_arguments = {
    # ... potentially other arguments ...
    "--job-language"                     = "python"
    "‑‑job‑bookmark‑option"              = "job-bookmark-enable"
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.json_to_parquet_logs.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.glue_bucket_assets.bucket}/sparkHistoryLogs/"
    "--enable-metrics"                   = ""
    "--TempDir"                          = "s3://${aws_s3_bucket.glue_bucket_assets.bucket}/temporary/"
    "--enable-continuous-log-filter"     = "true"
    "--class"                            = "GlueApp"
    "--server-side-encryption"           = "true"

  }

}

resource "aws_glue_job" "xml_to_parquet" {
  name     = "xml_to_parquet"
  role_arn = var.aws_iam_role

  command {
    script_location = "s3://${aws_s3_bucket.glue_bucket_assets.bucket}/scripts/xml-to-parquet.py"
    python_version  = 3
  }

  glue_version      = "2.0"
  max_retries       = 0
  worker_type       = "G.1X"
  number_of_workers = 10

  security_configuration = aws_glue_security_configuration.glueSecuritySettings.id

  default_arguments = {
    # ... potentially other arguments ...
    "--job-language"                     = "python"
    "‑‑job‑bookmark‑option"              = "job-bookmark-enable"
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.xml_to_parquet_logs.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.glue_bucket_assets.bucket}/sparkHistoryLogs/"
    "--enable-metrics"                   = ""
    "--TempDir"                          = "s3://${aws_s3_bucket.glue_bucket_assets.bucket}/temporary/"
    "--enable-continuous-log-filter"     = "true"
    "--class"                            = "GlueApp"
    "--server-side-encryption"           = "true"

  }

}




#  aws-glue-assets-899479717296-us-east-1



