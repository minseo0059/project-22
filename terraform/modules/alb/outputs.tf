# ALB의 DNS 이름 출력 (예: my-alb-1234567890.region.elb.amazonaws.com)
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.this.dns_name  # 외부에서 ALB에 접근할 때 사용
}

# ALB의 호스팅 존 ID 출력 (Route53 레코드 생성 시 필요)
output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.this.zone_id   # ALB의 정식 호스팅 영역 ID
}

# ALB의 ARN 출력 (다른 리소스에서 참조용)
output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.this.arn       # Amazon Resource Name
}

# 타겟 그룹 ARN 출력 (리스너 규칙 등에서 참조)
output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.this.arn  # 생성된 타겟 그룹 식별자
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "alb_arn_suffix" {
  description = "ALB의 ARN 접미사"
  value       = aws_lb.this.arn_suffix # aws_lb.main은 ALB 리소스의 이름에 따라 다를 수 있습니다.
}
