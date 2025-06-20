resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.name}-ec2-sg-"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id # VPC 모듈에서 전달받은 VPC ID

  # SSH (22번 포트) 인바운드 규칙 허용 (모든 IP에서 접근 가능하도록 설정. 보안상 특정 IP로 제한 권장)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 실제 환경에서는 특정 IP 대역으로 제한하는 것이 좋습니다.
  }

  # HTTP (80번 포트) 인바운드 규칙 허용 (애플리케이션이 웹 서버를 구동할 경우)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 실제 환경에서는 ALB 또는 특정 IP 대역으로 제한 권장
  }

  # HTTPS (443번 포트) 인바운드 규칙 허용 (애플리케이션이 HTTPS 웹 서버를 구동할 경우)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 실제 환경에서는 ALB 또는 특정 IP 대역으로 제한 권장
  }

  # 아웃바운드 규칙 (모든 트래픽 허용)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-ec2-sg"
  })
}

# 최신 Amazon Linux 2 AMI ID를 동적으로 조회
data "aws_ami" "latest_amazon_linux" {
  most_recent = true # 가장 최신 AMI를 선택
  owners      = ["amazon"] # Amazon이 소유한 AMI만 검색

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Amazon Linux 2 AMI 패턴
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  # EC2 인스턴스 모듈이 실행되는 AWS 리전 (서울 리전)에 따라 동적으로 AMI를 찾습니다.
  # 이 data 소스는 해당 모듈이 프로비저닝될 리전을 기반으로 합니다.
  # provider = aws.<region_alias>  # 만약 다른 리전에서 AMI를 찾는다면 alias를 사용
}

# 미리 생성된 IAM Role ("EC2_RDS,S3_full")을 조회합니다.
# 이 데이터 소스는 해당 이름의 Role이 AWS에 존재해야만 정상 작동합니다.
data "aws_iam_role" "existing_ec2_role" {
  name = var.ec2_iam_role_name # modules/ec2/variables.tf에서 전달받은 Role 이름
}

# EC2 인스턴스에 IAM Role을 연결하기 위한 Instance Profile
# 이 Profile은 위에서 조회한 data.aws_iam_role.existing_ec2_role을 참조합니다.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name}-ec2-profile"
  # 조회한 Role의 이름을 참조합니다.
  role =  data.aws_iam_role.existing_ec2_role.name # <-- 이 부분을 변경합니다.

  tags = merge(var.tags, {
    Name = "${var.name}-ec2-profile"
  })
}

# EC2 인스턴스 생성
resource "aws_instance" "app_instance" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id # 퍼블릭 또는 프라이빗 서브넷 선택
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id] # 위에서 정의한 보안 그룹 연결
  key_name                    = var.key_pair_name # SSH 접속을 위한 키 페어 이름
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  # 탄력적 IP를 할당하려면 public_ip 변수를 true로 설정하고, 퍼블릭 서브넷에 배치해야 합니다.
  associate_public_ip_address = var.associate_public_ip_address

  # User data (인스턴스 부트스트랩 스크립트) - 선택 사항
  # user_data = filebase64("${path.module}/user_data.sh") # 예시: user_data.sh 파일 사용

  tags = merge(var.tags, {
    Name = "${var.name}-app-instance"
  })
}
