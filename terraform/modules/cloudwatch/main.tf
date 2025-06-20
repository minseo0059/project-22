# modules/cloudwatch/main.tf

# 1. EC2/EKS 모니터링 (EC2 인스턴스에 대한 일반적인 CPU 사용률 및 상태 확인)
# EKS 노드 그룹은 내부적으로 EC2 인스턴스이므로, EC2 지표를 사용하여 모니터링 가능
resource "aws_cloudwatch_metric_alarm" "eks_cpu_utilization_alarm" {
  alarm_name          = "${var.name}-eks-cpu-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5분
  statistic           = "Average"
  threshold           = 80 # CPU 사용률 80% 초과 시 알람
  alarm_description   = "EKS Cluster (EC2 Instances) CPU Utilization"
  # EKS 클러스터의 모든 노드에 대한 CPU 사용률을 모니터링하려면,
  # Target group이나 Auto Scaling Group 지표를 사용하거나,
  # EKS 노드들이 속한 Auto Scaling Group ID를 기준으로 필터링할 수 있습니다.
  # 여기서는 간단하게 EC2 전체의 CPUUtilization을 모니터링하는 예시입니다.
  # 실제 EKS 노드 그룹에 특화된 모니터링을 원하면 Dimension을 추가해야 합니다.
  # dimensions = {
  #   AutoScalingGroupName = "your-eks-nodegroup-asg-name"
  # }
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "eks_status_check_failed_alarm" {
  alarm_name          = "${var.name}-eks-status-check-failed-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300 # 5분
  statistic           = "Maximum"
  threshold           = 0 # 0 초과 (즉, 실패 발생) 시 알람
  alarm_description   = "EKS Cluster (EC2 Instances) Status Check Failed"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

# 2. RDS(MariaDB) 모니터링
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization_alarm" {
  alarm_name          = "${var.name}-rds-cpu-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300 # 5분
  statistic           = "Average"
  threshold           = 70 # CPU 사용률 70% 초과 시 알람
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }
  alarm_description   = "RDS Instance CPU Utilization"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_space_alarm" {
  alarm_name          = "${var.name}-rds-free-storage-space-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300 # 5분
  statistic           = "Average"
  threshold           = 5000000000 # 5GB (바이트 단위) 미만 시 알람
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }
  alarm_description   = "RDS Instance Free Storage Space"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

# 3. ALB 모니터링
resource "aws_cloudwatch_metric_alarm" "alb_5xx_count_alarm" {
  alarm_name          = "${var.name}-alb-5xx-count-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300 # 5분
  statistic           = "Sum"
  threshold           = 5 # 5분 동안 5XX 에러 5회 이상 발생 시 알람
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
  alarm_description   = "ALB 5XX Error Count"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

# 4. CloudFront 모니터링
resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_error_rate_alarm" {
  alarm_name          = "${var.name}-cloudfront-5xx-error-rate-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300 # 5분
  statistic           = "Average"
  threshold           = 1 # 5xx 에러 비율 1% 초과 시 알람
  dimensions = {
    DistributionId = var.cloudfront_distribution_id
    Region         = "Global" # CloudFront 지표는 Global Region에 존재
  }
  alarm_description   = "CloudFront 5XX Error Rate"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_total_error_rate_alarm" {
  alarm_name          = "${var.name}-cloudfront-total-error-rate-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TotalErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300 # 5분
  statistic           = "Average"
  threshold           = 1 # 전체 에러 비율 1% 초과 시 알람
  dimensions = {
    DistributionId = var.cloudfront_distribution_id
    Region         = "Global" # CloudFront 지표는 Global Region에 존재
  }
  alarm_description   = "CloudFront Total Error Rate"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

# 5. S3 모니터링 (S3 버킷 수준의 지표는 CloudWatch에서 기본적으로 제공되지 않으며, S3 요청 지표는 CloudFront를 통해 확인하는 경우가 많습니다.)
# S3에 대한 BytesDownloaded/Uploaded 및 AllRequests 지표는 S3 서버 액세스 로깅을 CloudWatch Logs로 보내고 거기서 Metric Filter를 생성하거나,
# S3 Request Metrics를 활성화하여 CloudWatch로 보내야 합니다.

resource "aws_cloudwatch_metric_alarm" "s3_all_requests_alarm" {
  alarm_name          = "${var.name}-s3-all-requests-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "AllRequests"
  namespace           = "AWS/S3"
  period              = 300 # 5분
  statistic           = "Sum"
  threshold           = 1000 # 5분 동안 1000개 이상의 요청 발생 시 알람 (예시 값)
  dimensions = {
    BucketName = var.s3_bucket_name
    StorageType = "StandardStorage" # 혹은 다른 스토리지 타입
  }
  alarm_description   = "S3 All Requests Count"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "s3_bytes_downloaded_alarm" {
  alarm_name          = "${var.name}-s3-bytes-downloaded-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BytesDownloaded"
  namespace           = "AWS/S3"
  period              = 300 # 5분
  statistic           = "Sum"
  threshold           = 10000000000 # 10GB (바이트 단위) 초과 시 알람 (예시 값)
  dimensions = {
    BucketName = var.s3_bucket_name
    StorageType = "StandardStorage"
  }
  alarm_description   = "S3 Bytes Downloaded"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "s3_bytes_uploaded_alarm" {
  alarm_name          = "${var.name}-s3-bytes-uploaded-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BytesUploaded"
  namespace           = "AWS/S3"
  period              = 300 # 5분
  statistic           = "Sum"
  threshold           = 10000000000 # 10GB (바이트 단위) 초과 시 알람 (예시 값)
  dimensions = {
    BucketName = var.s3_bucket_name
    StorageType = "StandardStorage"
  }
  alarm_description   = "S3 Bytes Uploaded"
  actions_enabled     = false # SNS 기능을 사용하지 않으므로 알람 액션 비활성화
  tags                = var.tags
}
