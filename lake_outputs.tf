output "bucket_names" {
  value = {
    for dns, details in module.s3_buckets :
    dns => ({ "bucket name" = details.name })
  }
}

output "bucket_arn" {
  value = {
    for dns, details in module.s3_buckets :
    dns => ({ "bucket arn" = details.bucketARN })
  }
}
