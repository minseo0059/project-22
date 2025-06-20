# ALB 기본 설정
variable "alb_name" {
  description = "The name of the ALB"  # ALB 이름 (고유해야 함)
  type        = string
  default     = "my-application-load-balancer"
}

variable "internal" {
  description = "Whether the ALB is internal or external"  # 내부 전용(true)인지 인터넷 연결(false)인지
  type        = bool
  default     = false  # 기본값: 공개형
}

variable "security_groups" {
  description = "List of security group IDs for the ALB"  # ALB에 적용할 보안 그룹 ID 목록
  type        = list(string)  # 필수 입력 (예: [sg-12345678])
}

variable "subnets" {
  description = "List of subnet IDs to deploy the ALB"  # ALB 배치 서브넷 (최소 2개 이상 권장)
  type        = list(string)  # 필수 입력 (예: ["subnet-123", "subnet-456"])
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"  # 실수로 삭제되는 것 방지
  type        = bool
  default     = true  # 운영환경에서는 true 권장
}

variable "tags" {
  description = "Tags to apply to the ALB"  # 리소스 태그 (예: { Environment = "prod" })
  type        = map(string)
  default     = {}  # 기본값: 태그 없음
}

# 타겟 그룹 설정
variable "target_group_name" {
  description = "The name of the target group"  # 타겟 그룹 이름 (고유해야 함)
  type        = string
  default     = "my-target-group"
}

variable "target_group_port" {
  description = "The port for the target group"  # 대상 애플리케이션 포트
  type        = number
  default     = 80  # 기본값: HTTP(80)
}

variable "target_group_protocol" {
  description = "The protocol for the target group"  # HTTP/HTTPS 선택
  type        = string
  default     = "HTTP"  # ALB와 타겟 그룹 간 프로토콜
}

variable "vpc_id" {
  description = "The VPC ID where the target group will be created"  # 타겟 그룹이 속한 VPC
  type        = string  # 필수 입력 (예: "vpc-12345678")
}

# 헬스 체크 설정
variable "health_check_path" {
  description = "The health check path for the target group"  # 헬스 체크 엔드포인트
  type        = string
  default     = "/health"  # 기본값: 루트 경로
}

variable "health_check_interval" {
  description = "The health check interval in seconds"  # 헬스 체크 주기
  type        = number
  default     = 30  # 기본값: 30초
}

variable "health_check_timeout" {
  description = "The health check timeout in seconds"  # 응답 대기 시간
  type        = number
  default     = 5  # interval보다 작아야 함
}

variable "healthy_threshold" {
  description = "The number of successful health checks before considering an instance healthy"  # 정상 판정 기준
  type        = number
  default     = 2  # 기본값: 2회 연속 성공
}

variable "unhealthy_threshold" {
  description = "The number of failed health checks before considering an instance unhealthy"  # 비정상 판정 기준
  type        = number
  default     = 2  # 기본값: 2회 연속 실패
}

# SSL 인증서 설정
variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for HTTPS listener"  # HTTPS에 사용할 인증서 ARN
  type        = string  # 필수 입력 (예: "arn:aws:acm:region:account:certificate/123...")
}
