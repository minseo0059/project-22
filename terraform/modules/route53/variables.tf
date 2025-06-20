# modules/route53/variables.tf
variable "hosted_zone_id" {  # 기존 zone_id → hosted_zone_id로 변경
  type        = string
  description = "Route53 호스팅 존 ID"
}

variable "record_name" {     # 기존 domain_name → record_name으로 변경
  type        = string
  description = "생성할 레코드 이름 (예: www.5585in.click)"
}

variable "cloudfront_domain_name" {    # ALB DNS 이름
  type        = string
  description = "CloudFront 배포 도메인 이름 (예: d1234abcd.cloudfront.net)"
}

variable "cloudfront_zone_id" {     # ALB의 Zone ID
  type        = string
  description = "CloudFront 호스팅 존 ID (예: Z2FDTNDATAQYW2)"
}
