# 생성된 버킷 이름 출력 (다른 모듈에서 참조용)
output "bucket_name" {
  value = aws_s3_bucket.this.bucket  # 예: "my-unique-bucket-name-2023"
}

# 버킷 ARN 출력 (IAM 정책 등에서 참조)
output "bucket_arn" {
  value = aws_s3_bucket.this.arn  # 예: "arn:aws:s3:::my-unique-bucket-name-2023"
}
