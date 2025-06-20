variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
  default     = "photoprism-eks"
}

variable "cluster_version" {
  description = "쿠버네티스 버전"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "VPC ID (기존 VPC 모듈에서 전달받음)"
  type        = string
}

variable "private_subnets" {
  description = "프라이빗 서브넷 ID 리스트 (기존 VPC 모듈에서 전달받음)"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ALB security group ID for node group ingress rule"
  type        = string
}

variable "node_instance_type" {
  description = "노드 인스턴스 타입"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "노드 그룹의 desired capacity"
  type        = number
  default     = 2
}
variable "key_pair_name" {
  description = "EC2 SSH 접속을 위한 키 페어 이름 (필수)"
  type        = string
  # 이 변수는 반드시 사용자 환경에 맞는 기존 키 페어 이름을 입력해야 합니다.
  default = "project"
}

variable "region" {
  description = "AWS 리전"
  type        = string
}

variable "service_account_name" {
  description = "ALB Controller에 사용할 서비스 계정 이름"
  type        = string
  default     = "aws-load-balancer-controller"
}
