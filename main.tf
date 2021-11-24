module "s3_buckets" {
  count              = length(local.bucket_names)
  bucket_name        = local.bucket_names[count.index]
  kms_master_key_arn = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
  source             = "./modules/s3"
  accounts_allowed   = var.accounts_allowed
}

module "security_lake_iam" {
  sor_bucket_name  = var.sor_bucket_name
  source           = "./modules/iam"
  spec_bucket_name = var.spec_bucket_name
  depends_on = [
    module.s3_buckets
  ]
}


module "security_lake_glue" {
  aws_iam_role       = module.security_lake_iam.glueServiceRole
  aws_s3_bucket      = var.sor_bucket_name
  glue_database_name = var.glue_database_name
  source             = "./modules/glue"
  spec_bucket_name   = var.spec_bucket_name
  depends_on = [
    module.s3_buckets,
    module.security_lake_iam
  ]
}

module "security_lake" {
  count                 = length(local.bucket_names)
  admin_role_name       = var.admin_role_name
  bucket_arn            = module.s3_buckets[count.index].bucketARN
  glu_service_role_name = module.security_lake_iam.glueServiceRole
  glue_database_name    = var.glue_database_name
  source                = "./modules/lake"
  depends_on = [
    module.s3_buckets,
    module.security_lake_iam,
    module.security_lake_glue
  ]
}


