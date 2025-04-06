locals {

  nat_instance_user_data = <<-EOT
    #!/bin/bash
    sudo yum install iptables-services -y
    sudo systemctl enable iptables
    sudo systemctl start iptables
    sudo echo "net.ipv4.ip_forward=1" | sudo /bin/tee /etc/sysctl.d/nat-ip-forwarding.conf
    sudo sysctl -p /etc/sysctl.d/nat-ip-forwarding.conf
    sudo /sbin/iptables -t nat -F
    sudo /sbin/iptables -t nat -A POSTROUTING -s ${var.vpc_cidr} -j MASQUERADE
    sudo /sbin/iptables -F FORWARD
    sudo service iptables save
  EOT
}

################################################################################
# NAT instance IAM role/profile
################################################################################
resource "aws_iam_role" "nat_instance_role_ssm" {
  count = var.nat_instance_iam_profile == "use_built_in" ? 1 : 0
  name = "NatInstanceRoleForSSM"
  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "nat_instance_role_policy_attachment" {
  count = var.nat_instance_iam_profile == "use_built_in" ? 1 : 0
  role       = aws_iam_role.nat_instance_role_ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat_instance_iam_profile" {
  count = var.nat_instance_iam_profile == "use_built_in" ? 1 : 0
  name = "NatInstanceIamProfile"
  role = aws_iam_role.nat_instance_role_ssm[0].name
}

################################################################################
# NAT instance security group
################################################################################
resource "aws_security_group" "nat_instance_security_group" {
  count = var.nat_instance_enabled ? 1 : 0
  name = "nat-instance-gw"
  description = "Security group for NAT instance"
  vpc_id = aws_vpc.self.id

  ingress = [
    {
      description = "Ingress (VPC traffic)"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [var.vpc_cidr]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = true
    }
  ]

  egress = [
    {
      description = "Egress traffic"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = true
    }
  ]
}

################################################################################
# NAT instance and ENI
################################################################################
resource "aws_network_interface" "nat_instance_nic" {
  count = var.nat_instance_enabled ? 1 : 0
  subnet_id = element([for subnet in aws_subnet.public: subnet.id], 0)
  source_dest_check = false
  security_groups = [aws_security_group.nat_instance_security_group[0].id]

  tags = {
    Name = "NatInstanceNIC"
  }
}

resource "aws_instance" "nat_instance" {
  count = var.nat_instance_enabled ? 1 : 0
  ami = var.nat_instance_ami
  instance_type = var.nat_instance_type
  iam_instance_profile = var.nat_instance_iam_profile == "use_built_in" ? aws_iam_instance_profile.nat_instance_iam_profile[0].name : var.nat_instance_iam_profile
  key_name = var.nat_instance_key_pair_name != "" ? var.nat_instance_key_pair_name : null
  monitoring = true
  network_interface {
    network_interface_id = aws_network_interface.nat_instance_nic[0].id
    device_index = 0
  }
  user_data = var.nat_instance_user_data == "" ? local.nat_instance_user_data : var.nat_instance_user_data
  user_data_replace_on_change = true
  tags = {
    Name = "nat_instance"
    Role = "nat"
  }
}