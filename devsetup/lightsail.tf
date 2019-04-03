provider "aws" {
  region = "ap-southeast-2"
}



resource "aws_lightsail_key_pair" "ssh_key" {
    name = "ssh_key"
}

output "private_key" {
  value = "${aws_lightsail_key_pair.ssh_key.private_key}"
}

# Create a new GitLab Lightsail Instance
resource "aws_lightsail_instance" "devbox" {
  name              = "DevBox"
  availability_zone = "ap-southeast-2a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "small_2_2"
  key_pair_name     = "${aws_lightsail_key_pair.ssh_key.name}"

  user_data        = "${file("${path.cwd}/data/user_data.txt")}"
}


