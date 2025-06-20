# 원본 서버 도메인 (필수)
variable "origin_domain" {
  description = "The domain name of the origin (e.g., ALB DNS name)"
  type        = string  # 예: "my-alb-123456789.ap-northeast-2.elb.amazonaws.com"
}

# 오리진 식별자 (선택)
variable "origin_id" {
  description = "A unique identifier for the origin"
  type        = string
  default     = "my-cloudfront-origin"  # 여러 오리진 구성 시 구분용
}

# ACM 인증서 ARN (필수)
variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for CloudFront"
  type        = string  # 반드시 us-east-1 리전의 인증서여야 함
}

# 사용자 정의 도메인 (필수)
variable "domain_name" {
  description = "The domain name to associate with CloudFront"
  type        = string  # 예: "example.com"
}

variable "default_root_object" {
  description = "The default root object (e.g., index.html)"
  type        = string
  default     = ""  # 루트 경로(/) 접속 시 서빙할 파일
}

# 배포 활성화 여부 (선택)
variable "enabled" {
  description = "Whether the CloudFront distribution is enabled"
  type        = bool
  default     = true  # false 시 배포 비활성화 (유지보수 모드)
}

# 추가 도메인 별칭 (선택)
variable "aliases" {
  description = "List of aliases (domains) for the CloudFront distribution"
  type        = list(string)
  default     = []  # 예: ["www.example.com", "cdn.example.com"]
}

# 가격 클래스 (선택)
variable "price_class" {
  description = "The price class for CloudFront (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"  # 북미/유럽 주요 지역만 포함 (비용 최적화)
}

# WAF 웹 ACL ID (선택)
variable "web_acl_id" {
  description = "The ID of the AWS WAF web ACL to associate with CloudFront"
  type        = string
  default     = ""  # WAF 적용 시 "waf-12345678" 형식으로 지정
}

# 리소스 태그 (선택)
variable "tags" {
  description = "Tags to apply to the CloudFront distribution"
  type        = map(string)
  default     = {}  # 예: { Environment = "prod", Team = "DevOps" }
}
