# 기존 출력값 유지 (VPC/ALB/RDS)
output "vpc_id" {
  value = module.vpc.vpc_id
}

# EKS 출력값 추가
output "eks_endpoint" {
  description = "EKS 엔드포인트"
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "클러스터 이름"
  value = module.eks.cluster_name
}

output "kubeconfig_path" {
  description = "kubeconfig 위임"
  value = module.eks.kubeconfig_path
}

output "ecr_repository_url" {
  description = "ECR 리포지토리 URL"
  value       = module.ecr.repository_url
}

output "rds_endpoint" {
  description = "RDS 엔드포인트"
  value = module.rds.rds_endpoint
}

output "my_bucket_name" {
  description = "S3 버킷 이름"
  value = module.s3.bucket_name
}

output "alb_acm_certificate_arn" {
  description = "ALB에서 사용할 ACM 인증서 ARN"
  value       = module.acm_alb.acm_certificate_arn
}

output "ec2_instance_id" {
  description = "생성된 EC2 인스턴스 ID"
  value       = module.ec2.ec2_instance_id
}

output "ec2_public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP 주소"
  value       = module.ec2.ec2_public_ip
}
