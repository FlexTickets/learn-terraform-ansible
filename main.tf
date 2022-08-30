provider "null" {}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*20*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "sg_ssh_http" {
  name = "sg_ssh_http"

  # SSH access
  ingress {
    from_port   = "${var.sshport}"
    to_port     = "${var.sshport}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # WWW access
  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_ssh_http.id]
  user_data              = data.template_file.user_data.rendered

  tags = {
    Name = var.instance_name
  }
}

data "template_file" "user_data" {
  template = "${file("scripts/add-ssh-web-app.yaml")}"

  vars = {
    username  = "${var.username}"
    groupname = "${var.groupname}"
    sshport   = "${var.sshport}"
  }
}

resource "null_resource" "web" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.web.public_ip
      port        = "${var.sshport}"
      user        = var.username
      private_key = file("${var.ssh_private_key_file}")
      agent       = false
    }

    inline = ["exit"]
#    inline = ["echo 'Connected!!!!'"]
  }

  provisioner "local-exec" {
    command = <<EOT
        ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.username} -i '${aws_instance.web.public_ip},' \
        --private-key ${var.ssh_private_key_file} ${var.playbook} \
        --extra-vars '{"wait_script":"/u/workspace/terraform/aws/learn-terraform-ansible/scripts/wait4finish-cloud-init.sh","username":"${var.username}"}'
        EOT
  }
}
