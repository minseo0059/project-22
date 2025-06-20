# Terraform 설정 블록 - 필요한 프로바이더 및 버전 지정
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS 공식 프로바이더
      version = "~> 5.0"         # 버전 5.x 대 사용
    }
  }
}

# 미국 동부(버지니아 북부) 리전용 AWS 프로바이더 (CloudFront 인증서 발급을 위해 필요)
provider "aws" {
  alias  = "us_east_1"  # 별칭으로 구분 (기본 프로바이더와 분리)
  region = "us-east-1"  # CloudFront 인증서는 이 리전에서만 발급 가능
}

# ACM(Amazon Certificate Manager) 인증서 리소스 생성
resource "aws_acm_certificate" "this" {
  provider          = aws.us_east_1  # us-east-1 프로바이더 사용
  domain_name       = var.domain_name # 인증서 발급 대상 도메인 (변수로 전달)
  validation_method = "DNS"          # DNS 검증 방식 선택 (이메일 검증 대신)

  tags = var.tags  # 태그 적용 (기본값은 빈 맵)

  # 수명주기 설정 - 교체 시 새 리소스 생성 후 기존 리소스 삭제
  lifecycle {
    create_before_destroy = true
  }
}

# Route53 검증 레코드 생성 (ACM 인증서 검증용)
resource "aws_route53_record" "validation" {
  provider = aws.us_east_1  # us-east-1 프로바이더 사용

  # ACM 인증서에서 제공하는 도메인 검증 옵션을 for_each로 순회
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name   # 레코드 이름
      record = dvo.resource_record_value  # 레코드 값
      type   = dvo.resource_record_type   # 레코드 타입 (일반적으로 CNAME)
    }
  }

  allow_overwrite = true  # 기존 레코드 덮어쓰기 허용
  name            = each.value.name    # 레코드 이름 설정
  records         = [each.value.record] # 레코드 값 설정 (배열 형태)
  ttl             = 60    # TTL(Time-To-Live) 값 (초 단위)
  type            = each.value.type    # 레코드 타입 설정
  zone_id         = var.route53_zone_id  # Route53 호스팅 존 ID (변수로 전달)
}

# ACM 인증서 검증 완료 리소스
resource "aws_acm_certificate_validation" "this" {
  provider                = aws.us_east_1  # us-east-1 프로바이더 사용
  certificate_arn         = aws_acm_certificate.this.arn  # 검증할 인증서 ARN
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]  # 검증용 레코드 FQDN 목록
}
