variable "name" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
}

variable "vpc_id" {
  description = "EC2 인스턴스가 생성될 VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "EC2 인스턴스가 배치될 서브넷 ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t2.micro" # 프리티어 사용 가능
}

variable "key_pair_name" {
  description = "EC2 SSH 접속을 위한 키 페어 이름 (필수)"
  type        = string
  # 이 변수는 반드시 사용자 환경에 맞는 기존 키 페어 이름을 입력해야 합니다.
  # 예시: default = "my-ssh-key"
}

variable "associate_public_ip_address" {
  description = "퍼블릭 IP 자동 할당 여부"
  type        = bool
  default     = true
}

# ★★★★★ 여기에 IAM Role 이름 변수를 다시 추가합니다. ★★★★★
variable "ec2_iam_role_name" {
  description = "EC2 인스턴스에 연결할 IAM Role의 이름 (미리 생성된 Role의 이름)"
  type        = string
  default     = "EC2_RDS,S3_full" # 예시: default = "EC2_RDS,S3_full"
  # 여기에 실제 AWS 계정에 존재하는 S3 및 RDS Full Access 권한을 가진 Role의 이름을 입력합니다.
}
