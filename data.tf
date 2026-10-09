data "aws_key_pair" "key_pair" {
  key_name = "mykeypairs"  # Change this value for the exacty name of your keys
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  al2023_ami_id = nonsensitive(data.aws_ssm_parameter.al2023_ami.value)
}