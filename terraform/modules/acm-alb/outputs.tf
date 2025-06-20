# 생성된 ACM 인증서의 ARN(Amazon Resource Name) 출력
output "acm_certificate_arn" {
  value = aws_acm_certificate.alb.arn
  # 출력 예: arn:aws:acm:region:account:certificate/12345678-1234-1234-1234-123456789012
  # 이 출력값은 ALB 모듈 등에서 참조하여 SSL 인증서를 연결하는 데 사용됨
}
