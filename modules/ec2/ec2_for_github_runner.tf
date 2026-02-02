data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_id" "unique_id" {
  byte_length = 4
}

# --- Elastic IP (for static public IP) ---
resource "aws_eip" "web_server_eip" {
  domain = "vpc" # Use "vpc" for VPC-based EIPs
  # instance = aws_instance.my_instance.id    ## direct association with the EC2 instance will block rolling udpate(create_before_destroy)
  # use aws_eip_association
  tags = {
    Name = "WebServerStaticEIP"
  }
}


# resource "local_file" "startup_script" {
#   content = templatefile("${path.module}/startup-script.sh",{
#     server = "nginx"
#     version = "1"
#   })
#   filename = "" #"${path.module}/startup-script.sh"
# }


resource "aws_ssm_parameter" "secret" {
  name        = "/github/runner/pat"
  description = "github pat"
  type        = "SecureString"
  value       = file("${path.module}/github_PAT.secret")
}


locals {
  # GH_REPO_URL = "https://github.com/NaveenKumar-Y/${var.github_repo}"
  GH_ORG_URL = "https://github.com/Naveen-Kumar-Org"
  rendered_script = templatefile("${path.module}/github_runner_startup_script.sh", {
    # GH_PAT = var.github_pat_token
    GH_ORG_URL = local.GH_ORG_URL
    github_repo = var.github_repo
    GITHUB_ORG = "Naveen-Kumar-Org"
  })
}

resource "null_resource" "script_change_trigger" {
  triggers = {
    script_hash = sha256(local.rendered_script)
  }
  
}


resource "aws_network_interface" "ec2_interface" {
  
  subnet_id = var.ec2_public_subnet_id
  # private_ips = ["10.0.16.109"]
  security_groups = [resource.aws_security_group.allow_ssh.id]  

  lifecycle {
    replace_triggered_by = [ null_resource.script_change_trigger ]
    create_before_destroy = true  # EIP will take care of assigning IP to newer instance from old.
  }
  
}


resource "aws_iam_instance_profile" "github_runner_instance_profile" {
  name = "github_runner_instance_profile"
  path = "/"
  role = aws_iam_role.github_runner_role.id
}



resource "aws_instance" "my_instance" {
  depends_on = [ aws_ssm_parameter.secret ]
  ami = data.aws_ami.latest_amazon_linux.id
  # name = "my_ec2_instance"
  instance_type = "t2.micro"
  provider = aws

  key_name = var.ssh_pulbic_key_name

  ########### # not requried if custom network interface is used ############3
  # associate_public_ip_address = true  
  # vpc_security_group_ids      = var.vpc_security_group_ids
  # subnet_id                   = var.ec2_public_subnet_id
  ########################################################################

  network_interface {
    network_interface_id = aws_network_interface.ec2_interface.id
    device_index         = 0  # Primary network interface
  }

  # iam_instance_profile = var.ec2_instance_profile_name
  iam_instance_profile = aws_iam_instance_profile.github_runner_instance_profile.name

  # private_ip = "10.0.16.109"
  # public_dns = "naveen.compute-1.amazonaws.com"
  # monitoring = var.enable_monitoring

  # user_data = file("${path.module}/startup-script.sh")
  # user_data = templatefile("${path.module}/startup-script.sh", {
  #   # instance_id = self.id
  #   server = "nginx"
  #   version = "1"
  # })
  user_data = local.rendered_script

  lifecycle {
    replace_triggered_by = [ null_resource.script_change_trigger ]
    create_before_destroy = true  # EIP will take care of assigning IP to newer instance from old.
  }

  tags = {
    Name = "my_ec2_instance-${random_id.unique_id.hex}" # , the "Name" column you see in the console is populated by tag with the key Name (capital 'N').
  }
}

resource "aws_eip_association" "instance_asso_ip" {
  # instance_id   = aws_instance.my_instance.id  # direclty attaching to instance
  network_interface_id = aws_network_interface.ec2_interface.id
  allocation_id = aws_eip.web_server_eip.id
  depends_on = [ aws_instance.my_instance ]  # wait till new instance is up

}



resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_ssh.id
}

resource "aws_security_group_rule" "allow_outbound_traffic" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_ssh.id

  
}