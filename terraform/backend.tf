terraform {
  backend "s3" {
    bucket = "terraform-state-5585"
    key    = "terraform/infra.tfstate"
    region = "ap-northeast-2"
  }
}
