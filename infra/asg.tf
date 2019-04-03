resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "subnet1" {
  vpc_id     = "${aws_vpc.vpc1.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = "${aws_vpc.vpc1.id}"
  cidr_block = "10.0.2.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc1.id}"

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "subnet1_public" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id = "${aws_subnet.subnet1.id}"
}

resource "aws_route_table_association" "subnet2_public" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id = "${aws_subnet.subnet2.id}"
}

resource "aws_security_group" "webapp" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.vpc1.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }
}

resource "aws_security_group_rule" "ssh_ingress" {
  count = "${length(var.ssh_whitelist_cidrs)}"
  security_group_id = "${aws_security_group.webapp.id}"

  from_port = 22
  to_port = 22
  protocol = "TCP"

  cidr_blocks = "${var.ssh_whitelist_cidrs[count.index]}"
}

resource "aws_iam_role" "webapp" {
  name = "webapp"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "deployment_read_s3" {
  name        = "read_s3_bucket"
  path        = "/"
  description = "Read S3 deployment bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.deployment_artifacts.arn}"
    },
    {
      "Action": [
        "s3:Get*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.deployment_artifacts.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "deploy" {
  role       = "${aws_iam_role.webapp.name}"
  policy_arn = "${aws_iam_policy.deployment_read_s3.arn}"
}

resource "aws_iam_instance_profile" "webapp" {
  name = "webapp"
  role = "${aws_iam_role.webapp.name}"
}

resource "aws_key_pair" "ssh_key" {
  key_name = "sshkey"
  public_key = "${file(var.ssh_pub_key_path)}"
}


resource "aws_autoscaling_group" "webapp" {
  name                      = "webapp"
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.webapp.name}"
  vpc_zone_identifier       = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]

  tag {
    key                 = "Name"
    value               = "webapp"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
resource "aws_launch_configuration" "webapp" {
  name_prefix         = "webapp"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.webapp.name}"
  key_name = "${aws_key_pair.ssh_key.key_name}"

  # This is to simplify access to the instance
  associate_public_ip_address = true

  user_data = "${file("${path.cwd}/data/user_data.txt")}"

  security_groups = [
    "${aws_security_group.webapp.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }

}

data "aws_instance" "webapp" {
  filter {
    name   = "tag:Name"
    values = ["webapp"]
  }

  depends_on = ["aws_autoscaling_group.webapp"]
}

output "webapp_public_ip" {
  value = "${data.aws_instance.webapp.*.public_ip}"
}