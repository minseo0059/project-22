# modules/cloudwatch/variables.tf

variable "name" {
  description = "리소스 이름에 사용될 접두사"
  type        = string
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
}

variable "rds_instance_identifier" {
  description = "RDS DB 인스턴스 식별자"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB의 ARN 접미사 (ALB ARN에서 arn:aws:elasticloadbalancing:region:account-id:loadbalancer/ 뒤의 부분)"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 버킷 이름"
  type        = string
}
