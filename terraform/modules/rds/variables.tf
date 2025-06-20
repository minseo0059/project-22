# 리소스 이름 접두사 (모든 리소스 이름에 사용)
variable "name" {
  description = "리소스 이름 접두사"
  type        = string
  default     = "photoprism"  # 기본값: photoprism-* 형태로 리소스 생성
}

# 네트워크 구성 변수
variable "vpc_id" {
  description = "VPC ID"  # RDS가 배치될 VPC
  type        = string    # 필수 입력 (예: vpc-0123456789abcdef)
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록 (보안 그룹 규칙용)"  # RDS 접근 허용 대역
  type        = string    # 필수 입력 (예: "10.0.0.0/16")
}

variable "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 리스트"  # RDS 서브넷 그룹에 사용
  type        = list(string)  # 최소 2개 이상의 서브넷 ID 필요
}

variable "public_subnet_ids" {
  description = "프라이빗 서브넷 ID 리스트"  # RDS 서브넷 그룹에 사용
  type        = list(string)  # 최소 2개 이상의 서브넷 ID 필요
}

# 데이터베이스 기본 설정
variable "db_name" {
  description = "데이터베이스 이름"  # 초기 생성될 DB 이름
  type        = string  # 필수 입력 (예: "photoprismdb")
}

variable "username" {
  description = "마스터 사용자 이름"  # 관리자 계정
  type        = string
  default     = "admin"  # 운영환경에서는 기본값 변경 권장
}

variable "password" {
  description = "마스터 패스워드"  # 관리자 패스워드
  type        = string
  sensitive   = true  # Terraform 출력에서 값 숨김
  # 운영환경에서는 TF_VAR 환경변수나 Secrets Manager 사용 권장
}

# 인스턴스 사양 설정
variable "instance_class" {
  description = "DB 인스턴스 클래스"
  type        = string
  default     = "db.t3.micro"  # 프리티어 지원 인스턴스
}

variable "allocated_storage" {
  description = "할당 스토리지 크기 (GB)"
  type        = number
  default     = 20  # 프리티어 최대 용량
}

# 백업/복구 설정
variable "backup_retention_period" {
  description = "백업 보존 기간 (일)"
  type        = number
  default     = 7  # 7일간 자동 백업 보관
}

# 고가용성 설정
variable "multi_az" {
  description = <<-EOT
    멀티 AZ 활성화 여부 (기본값: false)
    true로 변경 시 자동으로 대기 인스턴스 생성됨
    주의: 변경 시 다운타임 발생 (운영환경에서는 유지보수 시간대에 변경 권장)
  EOT
  type        = bool
  default     = false  # 운영환경에서는 true로 설정 권장
}
