provider "google" {
  project = var.project
  region  = var.gcp_region
}

provider "aws" {
  region = var.aws_region
}