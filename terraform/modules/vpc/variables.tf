# 리소스 이름 접두사 (모든 리소스 이름에 사용)
variable "name" {
  type    = string
  default = "photoprism"  # 기본값: "photoprism-vpc", "photoprism-igw" 등으로 생성
}

# VPC CIDR 블록 (전체 VPC의 IP 대역)
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"  # 65,536개의 IP 주소 제공
}

# 퍼블릭 서브넷 CIDR 목록 (인터넷 접근 가능 서브넷)
variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]  # 각각 256개 IP (첫 4개와 마지막 1개 IP는 AWS 예약)
}

# 프라이빗 서브넷 CIDR 목록 (내부 전용 서브넷)
variable "private_subnets" {
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]  # NAT 게이트웨이 통해 아웃바운드만 가능
}

# 가용 영역(AZ) 목록 (서브넷 분산 배치용)
variable "azs" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]  # 서울 리전의 2개 AZ
  # 참고: 계정별로 사용 가능한 AZ 다를 수 있음
}
