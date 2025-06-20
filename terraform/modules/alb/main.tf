resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id  # VPC 모듈의 출력값 사용

  # HTTP(80) 인바운드 규칙
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP에서 접근 허용
  }

  # HTTPS(443) 인바운드 규칙
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP에서 접근 허용
  }

  # 아웃바운드 규칙 (모든 트래픽 허용)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"  # 보안 그룹 이름 태그
  }
}

# ALB(Application Load Balancer) 리소스 생성
resource "aws_lb" "this" {
  name               = var.alb_name               # ALB 이름 (기본값: "my-application-load-balancer")
  internal           = var.internal               # 내부/외부 ALB 여부 (기본값: false = 인터넷 연결형)
  load_balancer_type = "application"             # ALB 타입 지정 (ALB/NLB/GLB 중 선택)
  security_groups    = var.security_groups        # 연결할 보안 그룹 ID 목록 (필수 입력)
  subnets            = var.subnets                # ALB가 배치될 서브넷 ID 목록 (필수 입력)

  enable_deletion_protection = var.enable_deletion_protection  # ALB 삭제 방지 활성화 (기본값: true)

  tags = var.tags  # ALB에 적용할 태그 (기본값: 빈 맵 {})
}

# 타겟 그룹 리소스 생성 (ALB가 트래픽을 라우팅할 대상)
resource "aws_lb_target_group" "this" {
  name     = var.target_group_name      # 타겟 그룹 이름 (기본값: "my-target-group")
  port     = var.target_group_port      # 대상 애플리케이션 포트 (기본값: 80)
  protocol = var.target_group_protocol  # 프로토콜 (기본값: HTTP)
  vpc_id   = var.vpc_id                 # 대상이 위치한 VPC ID (필수 입력)

  # 헬스 체크 설정
  health_check {
    path                = var.health_check_path         # 헬스 체크 경로 (기본값: "/")
    interval            = var.health_check_interval     # 체크 간격(초) (기본값: 30)
    timeout             = var.health_check_timeout      # 타임아웃(초) (기본값: 5)
    healthy_threshold   = var.healthy_threshold         # 정상 판정 임계값 (기본값: 2회 성공)
    unhealthy_threshold = var.unhealthy_threshold       # 비정상 판정 임계값 (기본값: 2회 실패)
  }
}

# HTTPS 리스너 생성 (443 포트)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn  # 연결할 ALB ARN
  port              = "443"            # 리스너 포트
  protocol          = "HTTPS"          # 프로토콜
  ssl_policy        = "ELBSecurityPolicy-2016-08"  # SSL 정책 (AWS 관리형 기본 정책)
  certificate_arn   = var.acm_certificate_arn      # ACM 인증서 ARN (필수 입력)

  # 기본 액션 설정 (타겟 그룹으로 트래픽 전달)
  default_action {
    type             = "forward"       # 트래픽 전달 방식
    target_group_arn = aws_lb_target_group.this.arn  # 전달할 타겟 그룹 ARN
  }
}
