output "ec2_instance_id" {
  description = "생성된 EC2 인스턴스 ID"
  value       = aws_instance.app_instance.id
}

output "ec2_public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP 주소 (있는 경우)"
  value       = aws_instance.app_instance.public_ip
}

output "ec2_private_ip" {
  description = "EC2 인스턴스의 프라이빗 IP 주소"
  value       = aws_instance.app_instance.private_ip
}

output "ec2_security_group_id" {
  description = "EC2 인스턴스 보안 그룹 ID"
  value       = aws_security_group.ec2_sg.id
}
