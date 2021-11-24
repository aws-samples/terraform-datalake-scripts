resource "aws_iam_policy" "GlueServiceRolePolicy" {
  name        = "GlueServiceRolePolicy"
  path        = "/"
  description = "GlueServiceRolePolicy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        "Effect" : "Allow",
        "Action" : [
          "glue:*",
          "redshift:DescribeClusters",
          "redshift:DescribeClusterSubnetGroups",
          "iam:ListRoles",
          "iam:ListUsers",
          "iam:ListGroups",
          "iam:ListRolePolicies",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeInstances",
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSubnetGroups",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "cloudformation:DescribeStacks",
          "cloudformation:GetTemplateSummary",
          "dynamodb:ListTables",
          "kms:ListAliases",
          "kms:DescribeKey",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListDashboards"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*aws-glue-*/*",
          "arn:aws:s3:::aws-glue-*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "tag:GetResources"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:CreateBucket",
        "s3:PutBucketPublicAccessBlock"],
        "Resource" : [
          "arn:aws:s3:::aws-glue-*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:GetLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:/aws-glue/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack"
        ],
        "Resource" : "arn:aws:cloudformation:*:*:stack/aws-glue*/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:RunInstances"
        ],
        "Resource" : [
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ec2:*:*:key-pair/*",
          "arn:aws:ec2:*:*:image/*",
          "arn:aws:ec2:*:*:security-group/*",
          "arn:aws:ec2:*:*:network-interface/*",
          "arn:aws:ec2:*:*:subnet/*",
          "arn:aws:ec2:*:*:volume/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Resource" : [
          "arn:aws:ec2:*:*:instance/*"
        ],
        "Condition" : {
          "StringLike" : {
            "ec2:ResourceTag/aws:cloudformation:stack-id" : "arn:aws:cloudformation:*:*:stack/aws-glue-*/*"
          },
          "StringEquals" : {
            "ec2:ResourceTag/aws:cloudformation:logical-id" : "ZeppelinInstance"
          }
        }
      },
      {
        "Action" : [
          "iam:PassRole"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:iam::*:role/AWSGlueServiceRole*",
        "Condition" : {
          "StringLike" : {
            "iam:PassedToService" : [
              "glue.amazonaws.com"
            ]
          }
        }
      },
      {
        "Action" : [
          "iam:PassRole"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:iam::*:role/AWSGlueServiceNotebookRole*",
        "Condition" : {
          "StringLike" : {
            "iam:PassedToService" : [
              "ec2.amazonaws.com"
            ]
          }
        }
      },
      {
        "Action" : [
          "iam:PassRole"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:iam::*:role/service-role/AWSGlueServiceRole*"
        ],
        "Condition" : {
          "StringLike" : {
            "iam:PassedToService" : [
              "glue.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

}

resource "aws_iam_role" "AWSGlueServiceRoleDefault" {
  name                = "AWSGlueServiceRoleDefault"
  managed_policy_arns = [data.aws_iam_policy.AWSGlueServiceRole.arn, aws_iam_policy.GlueServiceRolePolicy.arn]

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
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:ListBucket", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::${var.sor_bucket_name}/*", "arn:aws:s3:::${var.spec_bucket_name}/*"]
          }, {
          Action   = ["s3:ListBucket"]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::${var.sor_bucket_name}", "arn:aws:s3:::${var.spec_bucket_name}"]
          }, {
          Action   = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"]
          Effect   = "Allow"
          Resource = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
        }
      ]
    })
  }

  depends_on = [aws_iam_policy.GlueServiceRolePolicy]
}




