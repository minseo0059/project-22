# VPC 리소스 생성 (가상 네트워크 환경)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr  # VPC의 IP 대역 (기본값: 10.0.0.0/16)
  enable_dns_support   = true          # DNS 해석 지원 활성화 (필수)
  enable_dns_hostnames = true          # 인스턴스에 DNS 호스트명 할당

  tags = {
    Name = "${var.name}-vpc"  # 리소스 식별 태그 (예: photoprism-vpc)
  }
}

# 인터넷 게이트웨이 (퍼블릭 서브넷의 인터넷 연결용)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id  # 생성된 VPC에 연결

  tags = {
    Name = "${var.name}-igw"  # 예: photoprism-igw
  }
}

# NAT 게이트웨이용 탄력적 IP (EIP)
resource "aws_eip" "nat" {
  domain = "vpc"  # VPC 내에서 사용하도록 설정
  # 주의: 계정당 EIP 기본 할당량 5개 (필요시 할당량 증가 요청 필요)
}

# NAT 게이트웨이 (프라이빗 서브넷의 아웃바운드 인터넷 접근 허용)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id  # 할당된 EIP 연결
  subnet_id     = aws_subnet.public[0].id  # 퍼블릭 서브넷에 배치 (NAT는 반드시 퍼블릭 서브넷에)

  tags = {
    Name = "${var.name}-nat"  # 예: photoprism-nat
  }
  # 참고: NAT 게이트웨이 시간당 비용 발생 (약 $0.045/시간)
}

# 퍼블릭 서브넷 생성 (count 기반 동적 생성)
resource "aws_subnet" "public" {
  count = length(var.public_subnets)  # public_subnets 변수 길이만큼 생성

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]  # 순차적 CIDR 할당
  availability_zone       = var.azs[count.index]            # 가용 영역 분배
  map_public_ip_on_launch = true  # 인스턴스 자동 퍼블릭 IP 할당

  tags = {
    Name = "${var.name}-public-${count.index}"  # 예: photoprism-public-0
  }
}

# 프라이빗 서브넷 생성
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]  # 퍼블릭 서브넷과 동일 AZ에 매칭

  tags = {
    Name = "${var.name}-private-${count.index}"  # 예: photoprism-private-0
  }
}

# 퍼블릭 라우팅 테이블 (인터넷 게이트웨이 연결)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"  # 모든 트래픽
    gateway_id = aws_internet_gateway.igw.id  # IGW로 라우팅
  }

  tags = {
    Name = "${var.name}-public-rt"  # 예: photoprism-public-rt
  }
}

# 퍼블릭 서브넷-라우팅 테이블 연결
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 프라이빗 라우팅 테이블 (NAT 게이트웨이 연결)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"  # 모든 트래픽
    nat_gateway_id = aws_nat_gateway.nat.id  # NAT로 라우팅 (아웃바운드 전용)
  }

  tags = {
    Name = "${var.name}-private-rt"  # 예: photoprism-private-rt
  }
}

# 프라이빗 서브넷-라우팅 테이블 연결
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
