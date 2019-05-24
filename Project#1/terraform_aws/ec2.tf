resource "aws_instance" "ec2" {
  ami                         = "ami-09f4cd7c0b533b081"
  instance_type               = "t2.micro"
  key_name                    = "Terraform"
  vpc_security_group_ids      = ["${aws_security_group.allow_ssh_http.id}"]
  subnet_id                   = "subnet-52df0f09"
}
