# 도메인 이름 변수
variable "domain_name" {
  type = string  # 문자열 타입 필수 입력
  # 설명: SSL 인증서를 발급할 도메인 이름 (예: example.com)
}

# Route53 호스팅 존 ID 변수
variable "route53_zone_id" {
  type = string  # 문자열 타입 필수 입력
  # 설명: DNS 검증을 수행할 Route53 호스팅 존 ID
}

# 태그 변수
variable "tags" {
  type    = map(string)  # 문자열 맵 타입
  default = {}  # 기본값은 빈 맵 (선택적 입력)
  # 설명: 리소스에 적용할 태그 (예: { Environment = "production" })
}
