# 버킷 이름 변수 (필수)
variable "bucket_name" {
  description = "S3 버킷 이름 (전역적으로 고유해야 하며, 소문자/숫자/하이픈(-)만 허용)"
  type        = string
  # 제약사항: 3~63자, IP 주소 형식 불가, xn-- 접두사 불가 등
}

# 환경 태그 변수 (선택)
variable "env" {
  description = "리소스 분류를 위한 환경 태그 (예: dev, staging, prod)"
  type        = string
  default     = "dev"  # 기본값: 개발 환경
}

# 버전 관리 활성화 변수 (선택)
variable "enable_versioning" {
  description = <<-EOT
    버전 관리 활성화 여부 (기본값: false)
    true 설정 시 파일 수정/삭제 시 이전 버전 보관
    주의: 저장 용량 증가 가능성 있음
  EOT
  type        = bool
  default     = false  # 기본값: 비활성화
}
