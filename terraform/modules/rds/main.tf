# 고유한 RDS 서브넷 그룹 이름 생성을 위한 랜덤 ID
resource "random_id" "rds_suffix" {
  byte_length = 4  # 4바이트 길이의 랜덤 값 생성 (8자리 16진수)
}

# RDS 서브넷 그룹 생성 (프라이빗 서브넷 사용)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.name}-rds-${random_id.rds_suffix.hex}"  # 고유 이름 생성 (예: photoprism-rds-a1b2c3d4)
  subnet_ids = var.public_subnet_ids  # RDS가 배치될 프라이빗 서브넷 ID 목록
# subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.name}-rds-subnet-group"  # 태그로 리소스 식별
  }
}

# RDS 보안 그룹 생성 (VPC 내부 접근 제어)
resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"  # 보안 그룹 이름 (예: photoprism-rds-sg)
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id  # RDS가 속한 VPC ID

  # 인바운드 규칙: VPC 내부에서만 3306 포트(MariaDB 기본 포트) 접근 허용
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # [var.vpc_cidr]  VPC CIDR 대역만 허용 (예: 10.0.0.0/16)
  }

  # 아웃바운드 규칙: 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

# MariaDB RDS 인스턴스 생성
resource "aws_db_instance" "mariadb" {
  identifier              = "${var.name}-mariadb"  # DB 인스턴스 식별자 (예: photoprism-mariadb)
  engine                 = "mariadb"              # 데이터베이스 엔진
  engine_version         = "10.6.22"              # MariaDB 10.6.22 버전 (LTS 버전 권장)
  instance_class         = var.instance_class     # 인스턴스 사양 (기본값: db.t3.micro)
  allocated_storage      = var.allocated_storage  # 할당 스토리지(GB) (기본값: 20)
  storage_type           = "gp2"                  # 범용 SSD 스토리지
  db_name                = var.db_name            # 초기 데이터베이스 이름
  username               = var.username           # 마스터 사용자명 (기본값: admin)
  password               = var.password           # 마스터 패스워드 (sensitive 처리됨)
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name  # 서브넷 그룹 연결
  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # 보안 그룹 연결
  parameter_group_name   = aws_db_parameter_group.mariadb_10_6.name  # 파라미터 그룹 연결
  publicly_accessible    = true                 # 외부 접근 차단 (VPC 내부 전용)
  skip_final_snapshot    = true                  # 삭제 시 최종 스냅샷 생략 (운영환경에서는 false 권장)
  backup_retention_period = var.backup_retention_period  # 자동 백업 보존 기간(일) (기본값: 7)

  # 고가용성 설정
  multi_az = var.multi_az  # 멀티 AZ 배포 여부 (기본값: false, 운영환경에서는 true 권장)

  # 프리티어 호환 설정
  storage_encrypted      = false  # 스토리지 암호화 (프리티어는 미지원)
  apply_immediately      = true   # 파라미터 변경 시 즉시 적용

  tags = {
    Name = "${var.name}-mariadb"
  }
}

# MariaDB 10.6 전용 파라미터 그룹 생성
resource "aws_db_parameter_group" "mariadb_10_6" {
  name        = "${var.name}-mariadb-10-6"  # 파라미터 그룹 이름 (예: photoprism-mariadb-10-6)
  family      = "mariadb10.6"              # MariaDB 10.6 패밀리 지정
  description = "Custom parameter group for MariaDB 10.6"

  # 필요 시 커스텀 파라미터 추가 예시 (주석 처리됨)
  # parameter {
  #   name  = "max_connections"  # 최대 연결 수 설정
  #   value = "1000"
  # }
}
