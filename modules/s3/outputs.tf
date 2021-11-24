output "name" {
  value = aws_s3_bucket.dl_bucket.id
}

output "bucketARN" {
  value = aws_s3_bucket.dl_bucket.arn
}
