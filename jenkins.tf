data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["education-vpc"]
  }
}

resource "aws_subnet" "example" {
  vpc_id = "${data.aws_vpc.selected.id}"
  cidr_block = "10.0.7.0/24"
  map_public_ip_on_launch = true
}
data "template_file" "userr_data" {
  template = "${file("install_jenkins.sh")}"
}

resource "aws_instance" "jenkins2" {
  ami             = "ami-0443305dabd4be2bc"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.example.id
  security_groups = ["${aws_security_group.jenn-security-group.id}"]
  key_name        = "${aws_key_pair.petclinic.id}"
  user_data       = file("install_jenkins.sh")
  tags = {
    Name = "jenkins2"
  }
}
output "jenkinsn_endpoint" {
  value = formatlist("/var/lib/jenkins/secrets/initialAdminPassword")
}
resource "aws_security_group" "jenn-security-group" {
  name        = "jenn-security-group"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    # SSH Port 22 allowed from any IP
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
      # SSH Port 80 allowed from any IP
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
}





resource "aws_key_pair" "petclinic" {
  key_name   = "petclinic-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJlceIY3JeiY/Th1ve92j+RngxVwyeARqry9NycbkhYzgP96QNWljht5UW6gz6dk3+nMQhG41JWI13vWtlOgHSLMvsSkhzgzB3TdA58OYzVYW3QHrxiyG2Cl3dqaTquEFpme0TBA6+nXER8RSmcHGvHTwOH2HDn70skBmh9jUWPCaHpJ5D/D8/oUWNutmOj58dufnuMRgxSHAvRi4iSu25hgxZIpdCXaHx1xjwmF+alvBgPFbG/0YXQdfwjzoOMxPY5mdxA8D2VNS/in6YX2JR4CVoUK9q7SMAKrkhwAT+8oaSlsDMOhgxaK5lt6cLkrFRSyQbQ1F0U6S7isE4opAH reddy@nagesh"
}