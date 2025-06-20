
# terraform/main.tf

# AWS 프로바이더 설정 (기본 리전)
provider "aws" {
  region = var.region  # variables.tf에서 정의한 리전 사용 (기본값: ap-northeast-2)
}
provider "kubernetes" {
  config_path = "${path.root}/kubeconfig_${var.cluster_name}"
}
provider "helm" {
  kubernetes {
    config_path = "${path.root}/kubeconfig_${var.cluster_name}"
  }
}

# 기존 Route53 호스팅 존 데이터 조회
data "aws_route53_zone" "existing" {
  zone_id = "Z07063203QA24KJ72X4MN"  # 기존 호스팅 존 ID
}

# VPC 모듈 호출 - 네트워크 인프라 구성
module "vpc" {
  source           = "./modules/vpc"
  name             = "${var.name}"  # 리소스 이름 접두사 (기본값: "photoprism")
  vpc_cidr         = "10.0.0.0/16"  # VPC CIDR 블록
  azs              = ["ap-northeast-2a", "ap-northeast-2c"]  # 가용 영역 설정
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]  # 퍼블릭 서브넷 CIDR
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]  # 프라이빗 서브넷 CIDR
}

# S3 버킷 모듈 호출 - 스토리지 구성
module "s3" {
  source            = "./modules/s3"
  bucket_name       = var.s3_config.bucket_name       # ← 루트 variables.tf에서 정의된 변수
  env               = "dev"
  enable_versioning = true
}

# 미국 동부(버지니아 북부) 리전용 AWS 프로바이더 (ACM 인증서 발급을 위해 필요)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# ACM 모듈 호출 - CloudFront용 SSL/TLS 인증서 발급
module "acm" {
  source          = "./modules/acm"
  domain_name     = var.domain_name  # 인증서 발급 대상 도메인
  route53_zone_id = var.route53_zone_id  # Route53 존 ID
  tags = {
    Environment = "dev"  # 환경 태그
  }

  providers = {
    aws = aws.us_east_1  # CloudFront 인증서는 us-east-1 리전에서만 발급 가능
  }
}

# ACM 모듈 호출 - ALB용 SSL/TLS 인증서 발급
module "acm_alb" {
  source          = "./modules/acm-alb"
  domain_name     = var.domain_name  # 인증서 발급 대상 도메인
  route53_zone_id = var.route53_zone_id  # Route53 존 ID
  tags            = var.tags  # 공통 태그 적용
}

# ALB(Application Load Balancer) 모듈 호출
module "alb" {
  source                = "./modules/alb"
  alb_name              = "my-app-alb"  # ALB 이름
  security_groups       = [module.alb.alb_sg_id]  # ALB 보안 그룹
  subnets               = module.vpc.public_subnet_ids  # 퍼블릭 서브넷에 배치
  vpc_id                = module.vpc.vpc_id  # VPC ID
  acm_certificate_arn   = module.acm_alb.acm_certificate_arn  # ALB에 적용할 인증서 ARN
  target_group_port     = 31861 # nodePort 로 타겟포트 지정
  enable_deletion_protection = false  # ALB 삭제 방지 비활성화 (운영환경에서는 true 권장)
}

# Route53 모듈 호출 - DNS 레코드 설정
module "route53" {
  source         = "./modules/route53"
  hosted_zone_id = data.aws_route53_zone.existing.zone_id  # 기존 존 ID 사용
  record_name    = var.domain_name  # 생성할 레코드 이름 (서브도메인)
  cloudfront_domain_name = module.cloudfront.domain_name  # CloudFront 도메인 (ex: d1234abcd.cloudfront.net)
  cloudfront_zone_id     = module.cloudfront.zone_id      # CloudFront의 존 ID ( 꼭 필요 )
}

# CloudFront 모듈 호출 - CDN 구성
module "cloudfront" {
  source              = "./modules/cloudfront"
  acm_certificate_arn = module.acm.acm_certificate_arn  # CloudFront용 인증서 ARN
  origin_domain       = module.alb.alb_dns_name  # ALB를 오리진으로 설정
  domain_name         = var.domain_name  # CloudFront에 연결할 도메인
}

# RDS 모듈 호출 - 데이터베이스 구성
module "rds" {
  source             = "./modules/rds"
  name               = "${var.name}"  # 리소스 이름 접두사
  vpc_id             = module.vpc.vpc_id  # VPC ID
  vpc_cidr           = module.vpc.vpc_cidr  # VPC CIDR
  private_subnet_ids = []  # ✅ 빈 값으로라도 넘기기
  public_subnet_ids  = module.vpc.public_subnet_ids  #  퍼블릭 서브넷에 배치 
  db_name            = var.rds_config.db_name  # 데이터베이스 이름
  username           = var.rds_config.db_user  # 마스터 사용자 이름
  password           = var.rds_config.db_password # 마스터 패스워드 (운영환경에서는 변수/시크릿 사용 권장)

  # 멀티 AZ 설정 (현재 비활성화)
  multi_az = false # 추후 true로 변경하면 멀티 AZ 활성화

  # 프리티어 호환 설정
  instance_class         = "db.t3.micro"  # 인스턴스 유형
  allocated_storage      = 20  # 할당된 스토리지(GB)
  backup_retention_period = 7  # 백업 보존 기간(일)
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "photoprism-eks"
  vpc_id          = module.vpc.vpc_id          # 기존 VPC 모듈 참조
  private_subnets = module.vpc.private_subnet_ids # 프라이빗 서브넷 전달
  alb_sg_id       = module.alb.alb_sg_id
  region          = var.region
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

# EKS ↔ RDS 보안 그룹 규칙 (루트에 추가)
resource "aws_security_group_rule" "eks_to_rds" {
  description              = "Allow EKS to access RDS"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.rds.rds_security_group_id
  source_security_group_id = module.eks.cluster_security_group_id
  type                     = "ingress"

    depends_on = [
    module.rds,
    module.eks
  ]
}

module "ecr" {
  source             = "./modules/ecr"
  repository_name    = "${var.name}-ecr"  # 기존 변수 활용 (예: photoprism-ecr)
  image_tag_mutability = "IMMUTABLE"      # 프로덕션 환경 권장
  keep_last_images   = 50                 # 유지할 이미지 개수
  tags               = var.tags           # 기존 태그 변수 재사용
  depends_on         = [module.eks] # EKS와 연동을 위한 IAM 정책 추가 (선택사항)
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  name   = var.name
  tags   = var.tags

  # 각 서비스 모듈의 출력값 연결
  rds_instance_identifier    = module.rds.rds_instance_identifier
  alb_arn_suffix             = module.alb.alb_arn_suffix
  cloudfront_distribution_id = module.cloudfront.cloudfront_distribution_id
  s3_bucket_name             = module.s3.bucket_name

  # CloudWatch 모듈이 의존하는 서비스들이 먼저 생성되도록 명시적 의존성 추가 (선택 사항이지만 안정성 향상)
  depends_on = [
    module.vpc,
    module.s3,
    module.alb,
    module.rds,
    module.eks,
    module.cloudfront,
    module.ecr # ECR에 대한 직접적인 CloudWatch 알람은 없지만, 전체 인프라 종속성을 고려
  ]
}

# EC2 모듈 호출 - 애플리케이션 서버 구성
module "ec2" {
  source = "./modules/ec2"
  name   = var.name
  tags   = var.tags

  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  key_pair_name = var.ec2_key_pair_name
  ec2_iam_role_name = var.ec2_iam_role_name
  depends_on    = [module.vpc]
}
