terraform {
  backend "s3" {
    bucket = "mk-tfstate"
    key    = "state_test"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

resource "aws_key_pair" "default" {
  key_name   = "default-key"
  public_key = "${var.ssh_key}"
}

resource "aws_security_group" "tftest" {
  name = "testsecgroup"
  description = "Test Security Group"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ebs_volume" "testebs" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["testtest"]
  }
}

resource "aws_instance" "tftest" {
  ami = "ami-0c0d066cb8b155cbe"
  instance_type = "t3.nano"
  key_name = "default-key"
  security_groups = ["${aws_security_group.tftest.name}"]
  tags {
    Name = "tftest"
  }

  provisioner "local-exec" {
    command = "sleep 120; ansible-playbook -u admin -i '${self.public_ip},' test.yml"
  }
}

resource "aws_volume_attachment" "testebs_attach" {
  device_name = "/dev/sdh"
  volume_id   = "${data.aws_ebs_volume.testebs.id}"
  instance_id = "${aws_instance.tftest.id}"
  skip_destroy = true
}

resource "aws_eip" "lb" {
  instance = "${aws_instance.tftest.id}"
  vpc = true
}
