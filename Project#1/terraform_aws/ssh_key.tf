resource "aws_key_pair" "terraform" {
  key_name   = "id_rsa"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
