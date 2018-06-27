provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

#ec2のroleとして作る場合に、いったんテンプレートのロールをつくって、そこに対して追加していく形でつくる必要がある？
resource "aws_iam_role" "sample-ec2-iam-role" {
  name = "sample-ec2-iam-role"
  path = "/"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Effect": "Allow",
       "Principal": {"Service": "ec2.amazonaws.com"},
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "code-dogfooding" {
  role       = "${aws_iam_role.sample-ec2-iam-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

## network

resource "aws_vpc" "sample-vpc" {
  cidr_block = "10.5.0.0/16"

  tags {
    Name = "tf-sample-vpc"
  }
}

resource "aws_default_network_acl" "code-dogfooding" {
  default_network_acl_id = "${aws_vpc.sample-vpc.default_network_acl_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "tf-sample"
  }
}

## ec2

# EC2 settings
resource "aws_default_security_group" "sample" {
  vpc_id = "${aws_vpc.sample-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "tf-sample"
  }
}

resource "aws_instance" "sample" {
  ami                    = "ami-bec974d8"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_default_security_group.sample.id}"]

  tags {
    Name = "tf-sample"
  }
}
