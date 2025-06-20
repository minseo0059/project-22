# AWS 리전 설정 변수
variable "region" {
  description = "AWS 리전 설정"
  type        = string
  default     = "ap-northeast-2"  # 기본값: 서울 리전
}

# 도메인 이름 변수
variable "domain_name" {
  type = string
  default = "5585in.click"  # 사용할 도메인 이름
}

# Route53 호스팅 존 ID 변수
variable "route53_zone_id" {
  type = string
  default = "Z07063203QA24KJ72X4MN"  # Route53 호스팅 존 ID
}

# 공통 태그 변수
variable "tags" {
  description = "공통 태그 (예: 프로젝트 이름 등)"
  type        = map(string)
  default     = {
    Project = "my-app"  # 프로젝트 이름
    Env     = "dev"     # 환경 (개발)
  }
}

# 리소스 이름 접두사 변수
variable "name" {
  description = "리소스 이름에 사용될 접두사 (예: my-app)"
  type        = string
  default     = "photoprism"  # 기본값 설정 (PhotoPrism 애플리케이션 관련 리소스 생성 시 사용)
}

variable "ecr_config" {
  description = "ECR 구성"
  type = object({
    repository_name    = string
    keep_last_images   = number
    image_tag_mutability = string
  })
  default = {
    repository_name    = "test-5585in"
    keep_last_images   = 30
    image_tag_mutability = "MUTABLE"
  }
}

variable "s3_config" {
  type = object({
    bucket_name = string
  })
  description = "S3 버킷 설정"
}

variable "rds_config" {
  type = object({
    db_name     = string
    db_user     = string
    db_password = string
  })
  description = "RDS 설정"
}

variable "rds_publicly_accessible" {
  description = "RDS 퍼블릭 액세스 여부 (보안 테스트용으로 true 설정 가능)"
  type        = bool
  default     = false  # 기본은 false로, 필요 시 CLI에서 true로 오버라이드 가능
}

variable "ec2_key_pair_name" {
  description = "EC2 SSH 접속을 위한 키 페어 이름 (AWS에 미리 생성되어 있어야 함)"
  type        = string
  default     = "project" # 예시: default = "my-web-server-key"
}

variable "ec2_iam_role_name" {
  description = "EC2 인스턴스에 연결할 IAM Role의 이름 (S3 및 RDS Full Access 권한 포함)"
  type        = string
  default     = "EC2_RDS,S3_full" # EC2에 연결할 IAM Role
}
