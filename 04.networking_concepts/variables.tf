variable "ec2_ami_id" {
  type = string
  default = "ami-0b5eea76982371e91" 
  # name: amzn2-ami-kernel-5.10-hvm-2.0.20221210.1-x86_64-gp2
  # desc: Amazon Linux 2 Kernel 5.10 AMI 2.0.20221210.1 x86_64 HVM gp2
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}