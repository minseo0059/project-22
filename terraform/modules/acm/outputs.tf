# ACM 모듈 출력값 정의
output "acm_certificate_arn" {
  value = aws_acm_certificate.this.arn  # 생성된 ACM 인증서의 ARN 출력
  # 이 출력값은 다른 모듈(예: CloudFront)에서 참조 가능
}
