# CDN를 가리키는 Route53 A 레코드 생성
resource "aws_route53_record" "alb_record" {
  zone_id = var.hosted_zone_id  # 도메인이 관리되는 호스팅 존 ID (예: Z00249552W4J3AD07FHL9)
  name    = var.record_name     # 생성할 레코드 이름 (예: www.example.com)
  type    = "A"                 # A 레코드 타입 (IPv4 주소 매핑)

  # CDN에 대한 별칭(Alias) 설정
  alias {
    name                   = var.cloudfront_domain_name  # CDN 도메인 주
    zone_id                = var.cloudfront_zone_id   # CDN의 호스팅 존 ID 
    evaluate_target_health = false             # 상태 검사 활성화 (비정상 시 자동 라우팅 중지)
  }
}
