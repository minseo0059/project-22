# 도메인 이름 변수 (필수 입력)
variable "domain_name" {
  type = string  # 문자열 타입
  # 예: "example.com" 또는 "*.example.com" (와일드카드 인증서)
  # 설명: SSL 인증서를 발급할 도메인 이름
}

# Route53 호스팅 존 ID 변수 (필수 입력)
variable "route53_zone_id" {
  type = string  # 문자열 타입
  # 예: "Z0123456789ABCDEFGHIJ"
  # 설명: 도메인의 DNS 검증을 수행할 Route53 호스팅 존 ID
}

# 태그 변수 (선택적 입력)
variable "tags" {
  type    = map(string)  # 문자열 맵 타입
  default = {}  # 기본값은 빈 맵
  # 예: { Environment = "production", Team = "DevOps" }
  # 설명: 리소스에 추가할 태그 (비용 추적, 리소스 관리 용이)
}
