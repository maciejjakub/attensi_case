terraform {
  required_version = ">= 1.2.3"
  required_providers {
    aws = ">= 4.26.0"
  }

  backend "local" {}
}

provider "aws" {
  region = "eu-west-1"
}