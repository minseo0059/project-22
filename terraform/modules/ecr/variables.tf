variable "repository_name" {
  description = "ECR 리포지토리 이름"
  type        = string
}

variable "image_tag_mutability" {
  description = "이미지 태그 변경 가능성 (MUTABLE/IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "푸시 시 이미지 스캔 활성화"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "암호화 타입 (AES256/KMS)"
  type        = string
  default     = "AES256"
}

variable "keep_last_images" {
  description = "유지할 최신 이미지 개수"
  type        = number
  default     = 30
}

variable "tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
}
