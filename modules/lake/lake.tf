resource "aws_lakeformation_data_lake_settings" "myLakeSettings" {

  admins = [data.aws_iam_role.myRole.arn]

  create_database_default_permissions {
    permissions = ["ALL"]
    principal   = "IAM_ALLOWED_PRINCIPALS"
  }

  create_table_default_permissions {
    permissions = ["ALL"]
    principal   = "IAM_ALLOWED_PRINCIPALS"
  }

}

resource "aws_lakeformation_resource" "lakeS3Resource" {
  arn      = var.bucket_arn
  role_arn = var.glu_service_role_name
}

resource "aws_lakeformation_permissions" "lakeS3LocationPermission" {
  principal   = var.glu_service_role_name
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = aws_lakeformation_resource.lakeS3Resource.arn
  }

  depends_on = [
    aws_lakeformation_resource.lakeS3Resource
  ]

}

resource "aws_lakeformation_permissions" "lakeDBPermissions" {
  principal   = var.glu_service_role_name
  permissions = ["ALL"]

  database {
    name = var.glue_database_name
  }

  depends_on = [
    aws_lakeformation_resource.lakeS3Resource
  ]

}
