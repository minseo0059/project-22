# ALB(Application Load Balancer)용 ACM(Amazon Certificate Manager) 인증서 생성
resource "aws_acm_certificate" "alb" {
  domain_name       = var.domain_name       # SSL 인증서를 발급할 도메인 (예: example.com)
  validation_method = "DNS"                # DNS 검증 방식 선택 (도메인 소유권 확인)

  tags = var.tags  # 리소스 태그 지정 (기본값은 빈 맵 {})

  # 수명주기 설정 - 인증서 교체 시 무중단 배포를 위해 새 인증서 생성 후 기존 인증서 삭제
  lifecycle {
    create_before_destroy = true
  }
}

# Route53에 DNS 검증 레코드 생성 (ACM 인증서 검증용)
resource "aws_route53_record" "alb_validation" {
  # ACM 인증서에서 제공하는 도메인 검증 옵션을 순회
  for_each = {
    for dvo in aws_acm_certificate.alb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name   # 검증 레코드 이름 (예: _x1.example.com)
      record = dvo.resource_record_value  # 검증 레코드 값 (예: _x1.acm-validations.aws.)
      type   = dvo.resource_record_type   # 레코드 타입 (항상 CNAME)
    }
  }

  allow_overwrite = true  # 기존 레코드 덮어쓰기 허용
  name    = each.value.name    # 레코드 이름 설정
  type    = each.value.type    # 레코드 타입 설정 (CNAME)
  ttl     = 60                # TTL(Time-To-Live) 값 (초 단위)
  zone_id = var.route53_zone_id  # 도메인이 등록된 Route53 호스팅 존 ID
  records = [each.value.record]  # 검증 레코드 값 (배열 형태로 지정)
}

# ACM 인증서 검증 완료 처리
resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn  # 검증할 인증서 ARN
  validation_record_fqdns = [for record in aws_route53_record.alb_validation : record.fqdn]  # 생성된 검증 레코드 FQDN 목록
  # 이 리소스는 모든 검증 레코드가 생성된 후 인증서 상태를 "발급됨"으로 변경
}
