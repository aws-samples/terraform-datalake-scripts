resource "aws_iam_policy" "dlPutAndListSecurityData" {
  name        = "dlPutAndListSecurityData"
  path        = "/"
  description = "dlPutAndListSecurityData"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket", "s3:PutObject", "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${var.sor_bucket_name}", "arn:aws:s3:::${var.sor_bucket_name}/*"]
      },
    ]
  })

}

resource "aws_iam_role" "dlS3WriteSecurityData" {
  name                = "dlS3WriteSecurityData"
  managed_policy_arns = [aws_iam_policy.dlPutAndListSecurityData.arn]

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })

  depends_on = [aws_iam_policy.dlPutAndListSecurityData]

}


resource "aws_iam_policy" "dlAssumeS3Role" {
  name        = "dlAssumeS3Role"
  path        = "/"
  description = "dlAssumeS3Role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.dlS3WriteSecurityData.arn
      },
    ]
  })

}

