# 생성된 VPC ID 출력 (다른 모듈에서 참조용)
output "vpc_id" {
  value = aws_vpc.main.id  # 형식: vpc-0123456789abcdef
}

# 퍼블릭 서브넷 ID 목록 출력 (예: ALB, Bastion 호스트 배치용)
output "public_subnet_ids" {
  value = aws_subnet.public[*].id  # 배열 형태 (예: ["subnet-123", "subnet-456"])
}

# 프라이빗 서브넷 ID 목록 출력 (예: RDS, EC2 배치용)
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

# VPC CIDR 블록 출력 (보안 그룹 규칙 설정용)
output "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  value       = aws_vpc.main.cidr_block  # 예: "10.0.0.0/16"
}
