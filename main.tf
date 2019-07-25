# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "grimoirelab_sec_group"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kibiter access from anywhere
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "grimoire_key_pair"
  public_key = "${file(pathexpand(var.public_key_path))}"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu*16.04*server*"]
  }
}

data "template_file" "grimoirelab-script" {
  count    = length(var.orgs)
  template = "${file("grimoirelab-script.tpl")}"
  vars     = {
    org            = "${element(var.orgs, count.index)}"
    user           = "ubuntu"
    home           = "/home/ubuntu"
    arthur_workers = 25
  }
}

resource "aws_instance" "grimoirelab" {
  count                  = length(var.orgs)
  instance_type          = "m4.4xlarge"
  ami                    = "${data.aws_ami.ubuntu.image_id}"
  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = "${aws_subnet.default.id}"
  user_data              = "${element(data.template_file.grimoirelab-script.*.rendered, count.index)}"
  availability_zone      = "${var.aws_region}a"
  root_block_device {
    volume_size           = 50
    delete_on_termination = true
  }
}

resource "aws_ebs_volume" "grimoirelab_volume" {
  count             = length(var.orgs)
  availability_zone = "${var.aws_region}a"
  size              = 100
}

resource "aws_volume_attachment" "grimoirelab_att" {
  count       = length(var.orgs)
  device_name = "/dev/sdh"
  volume_id   = "${element(aws_ebs_volume.grimoirelab_volume.*.id, count.index)}"
  instance_id = "${element(aws_instance.grimoirelab.*.id, count.index)}"
}
