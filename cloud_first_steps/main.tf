terraform {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  # access key and secret key will be read automatically by environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "east-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true # to make subnet public

  tags = {
    Name = "east-1a-subnet"
  }
}

resource "aws_subnet" "east-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true # to make subnet public

  tags = {
    Name = "east-1b-subnet"
  }
}

resource "aws_route_table_association" "east-1a" {
  subnet_id      = aws_subnet.east-1a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "east-1b" {
  subnet_id      = aws_subnet.east-1b.id
  route_table_id = aws_route_table.main.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "webserver01" {
  ami           = var.ec2_ami_id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.east-1a.id
  associate_public_ip_address = true # to generate public ip & dns

  user_data = file("${path.module}/lab_files/user-data")

  tags = {
    Name = "webserver01"
  }
}

resource "aws_instance" "webserver02" {
  ami           = var.ec2_ami_id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.east-1b.id
  associate_public_ip_address = true # to generate public ip & dns

  user_data = file("${path.module}/lab_files/user-data")

  tags = {
    Name = "webserver02"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "security-group-lab" {
  name        = "Security-Group-Lab"
  description = "HTTP Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "Security-Group-Lab"
  }
}

data "aws_instance" "webserver01" {
  instance_id = aws_instance.webserver01.id
}

data "aws_instance" "webserver02" {
  instance_id = aws_instance.webserver02.id
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.security-group-lab.id
  network_interface_id = data.aws_instance.webserver01.network_interface_id
}

resource "aws_network_interface_sg_attachment" "sg_attachment_web02" {
  security_group_id    = aws_security_group.security-group-lab.id
  network_interface_id = data.aws_instance.webserver02.network_interface_id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
# resource "aws_ebs_volume" "east-1a" {
#   availability_zone = "us-east-1a"
#   size              = 8
#   type = "gp2"

#   tags = {
#     Name = "volume.us-east-1a"
#   }
# }

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment
# resource "aws_volume_attachment" "ebs_att" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.east-1a.id
#   instance_id = aws_instance.webserver01.id
# }