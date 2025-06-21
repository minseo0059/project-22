terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"  # 최소 4.x 이상 권장
    }
  }
}
# CloudFront 배포 리소스 생성
resource "aws_cloudfront_distribution" "this" {
  # 오리진(Origin) 설정 - 트래픽이 전달될 원본 서버(ALB/S3 등)
  origin {
    domain_name = var.origin_domain  # 원본 도메인 (예: ALB DNS 이름)
    origin_id   = var.origin_id     # 오리진 식별자 (기본값: "my-cloudfront-origin")

    # 사용자 정의 오리진 설정 (ALB 사용 시 필요)
    custom_origin_config {
      http_port              = 80       # HTTP 접속 포트
      https_port             = 443      # HTTPS 접속 포트
      origin_protocol_policy = "https-only"  # 원본과의 통신 프로토콜 (HTTPS만 허용)
      origin_ssl_protocols   = ["TLSv1.2"]   # 허용할 SSL 프로토콜 버전
    }
  }

  enabled             = var.enabled  # 배포 활성화 여부 (기본값: true)
  default_root_object = var.default_root_object
  # 기본 캐시 동작 설정
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]  # 허용 HTTP 메서드
    cached_methods   = ["GET", "HEAD"]             # 캐시할 HTTP 메서드
    target_origin_id = var.origin_id               # 대상 오리진 지정
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # AWS Managed-CachingOptimized ID
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"  # AWS Managed-AllViewer ID
    # 전달 값 설정 (쿼리 문자열/쿠키 처리 방식)
#    forwarded_values {
#      query_string = true  # 쿼리 문자열 캐시 여부 (false=모든 요청 동일 캐시)
#      cookies {
#        forward = "all"    # 쿠키 전달 안 함 (캐시 적중률 향상)
#      }
    }

    min_ttl                = 0      # 최소 캐시 유지 시간(초)
    default_ttl            = 3600   # 기본 캐시 유지 시간(1시간)
    max_ttl                = 86400  # 최대 캐시 유지 시간(1일)
  }

  # 지역 제한 설정
  restrictions {
    geo_restriction {
      restriction_type = "none"  # 국가 제한 없음 (whitelist/blacklist도 가능)
    }
  }

  # 뷰어 인증서 설정 (SSL/TLS)
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn  # ACM 인증서 ARN (us-east-1 필수)
    ssl_support_method       = "sni-only"               # SNI 지원 방식
    minimum_protocol_version = "TLSv1.2_2021"           # 최소 SSL 프로토콜 버전
  }

  aliases = [var.domain_name]  # 사용자 정의 도메인 연결 (예: example.com)
}
