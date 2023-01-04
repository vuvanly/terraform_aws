resource "aws_security_group" "web-security-group" {
  name        = "Web-Security-Group"
  description = "Web Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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


  tags = {
    Name = "Web-Security-Group"
  }
}

resource "aws_instance" "webserver" {
  ami           = var.ec2_ami_id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true # to generate public ip & dns

  key_name = aws_key_pair.maintainer.id

  user_data = file("${path.module}/web-user-data")

  vpc_security_group_ids = [aws_security_group.web-security-group.id]

  tags = {
    Name = "webserver"
  }
}

resource "aws_security_group" "db-security-group" {
  name        = "Db-Security-Group"
  description = "Db Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Db-Security-Group"
  }
}

resource "aws_instance" "dbserver" {
  ami           = var.ec2_ami_id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private.id

  vpc_security_group_ids = [aws_security_group.db-security-group.id]

  tags = {
    Name = "dbserver"
  }
}

resource "aws_key_pair" "maintainer" {
  key_name   = "maintainer-key"
  public_key = file(var.ssh_public_key_path)
}