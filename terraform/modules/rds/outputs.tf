# RDS 엔드포인트 출력 (애플리케이션 연결용)
output "rds_endpoint" {
  description = "RDS 엔드포인트"
  value       = aws_db_instance.mariadb.endpoint  # 형식: endpoint:port (예: photoprism-mariadb.abc123.us-east-1.rds.amazonaws.com:3306)
}

# RDS 보안 그룹 ID 출력 (추가 규칙 적용용)
output "rds_security_group_id" {
  description = "RDS 보안 그룹 ID"
  value       = aws_security_group.rds_sg.id  # 형식: sg-0123456789abcdef
}

output "rds_instance_identifier" {
  description = "RDS DB 인스턴스 식별자"
  value       = aws_db_instance.mariadb.id # aws_db_instance.default는 RDS 인스턴스 리소스의 이름에 따라 다를 수 있습니다.
}
