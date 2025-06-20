# 호스팅 존 ID 출력 (다른 모듈에서 참조용)
output "hosted_zone_id" {
  description = "Route53 호스팅 존 ID"
  value       = var.hosted_zone_id  # 입력받은 존 ID를 그대로 출력
  # 참고: 실제 호스팅 존 조회 시 data 소스 사용 권장 (기본값 의존성 제거)
}
