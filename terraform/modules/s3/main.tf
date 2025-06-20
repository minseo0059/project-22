# S3 버킷 리소스 생성
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name  # 버킷 이름 (전역적으로 고유해야 함)

  force_destroy = true  # 버킷 내 파일이 있어도 강제 삭제 허용 (주의: 운영환경에서는 false 권장)

  tags = {
    Name        = var.bucket_name  # 버킷 이름 태그
    Environment = var.env          # 환경 태그 (예: dev, staging, prod)
  }
}

# 버킷 버전 관리 설정
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id  # 버전 관리를 적용할 버킷 지정

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"  # 3항 연산자로 버전 관리 활성화/비활성화
    # Enabled: 파일 변경 이력 보존
    # Suspended: 버전 관리 중지 (기존 버전 유지)
  }
}

# 버킷 공개 접근 차단 설정 (보안 강화)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id  # 설정을 적용할 버킷 지정

  # 모든 공개 접근 차단 (보안 모범 사례)
  block_public_acls   = true    # 1. 공개 ACL 설정 차단
  block_public_policy = true    # 2. 공개 정책 설정 차단
  ignore_public_acls  = true    # 3. 기존 공개 ACL 무시
  restrict_public_buckets = true  # 4. 버킷 정책을 통한 공개 접근 차단
}
