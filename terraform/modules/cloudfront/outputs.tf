# CloudFront 배포 도메인 이름 출력 (예: d123.cloudfront.net)
output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

# CloudFront 호스팅 존 ID (Route53 레코드 생성 시 사용)
output "cloudfront_hosted_zone_id" {
  description = "The hosted zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

# CloudFront 배포 ID (관리/수정 시 필요)
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

# CloudFront ARN (IAM 정책 등에서 참조)
output "cloudfront_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "zone_id" {
  value = aws_cloudfront_distribution.this.hosted_zone_id
}
