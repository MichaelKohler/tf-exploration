terraform {
  backend "s3" {
    bucket = "mk-tfstate"
    key    = "state_test_general"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

resource "aws_ebs_volume" "testebs" {
  availability_zone = "${var.aws_availability_zone}"
  size = "${var.ebs_storage_size}"
  tags = {
    Name = "testtest"
  }
}