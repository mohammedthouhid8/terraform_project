resource "aws_instance" "tf_ec2_instance1" {
  ami                         = "ami-0360c520857e3138f"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]
  key_name                    = "terraform_ec2"
  depends_on = [ aws_s3_bucket.tf_s3_bucket ]
  user_data                   = <<-EOF
                                #!/bin/bash

                                # Git clone 
                                git clone  https://github.com/verma-kunal/nodejs-mysql.git /home/ubuntu/nodejs-mysql
                                cd /home/ubuntu/nodejs-mysql

                                # install nodejs
                                sudo apt update -y
                                sudo apt install -y nodejs npm

                                # edit env vars
                                echo "DB_HOST=${local.rds_endpoint}" | sudo tee .env
                                echo "DB_USER=${aws_db_instance.default.username}" | sudo tee -a .env
                                sudo echo "DB_PASS=${aws_db_instance.default.password}" | sudo tee -a .env
                                echo "DB_NAME=${aws_db_instance.default.db_name}" | sudo tee -a .env
                                echo "TABLE_NAME=users" | sudo tee -a .env
                                echo "PORT=3000" | sudo tee -a .env

                                # start server
                                npm install
                                EOF
user_data_replace_on_change = true
  

  tags = {
    Name = "Nodejs-server"
  }
}

resource "aws_security_group" "tf_ec2_sg" {
  name        = "nodejs-server"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-03c63f57c5c371095"

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group_rule" "tls_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
  description       = "TLS from VPC"
}

resource "aws_security_group_rule" "ssh_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
  description       = "SSH"
}

resource "aws_security_group_rule" "tcp_in" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
  description       = "TCP"
}

resource "aws_security_group_rule" "all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
  description       = "Allow all outbound traffic"
}


# module "tf_module_ec2_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "5.3.0"
   
#     name        = "ec2-sg"   
#   description = "Security group for EC2"
#   ingress_rules = ["https=443-tcp", "ssh-tcp"]
#   ingress_with_cidr_blocks = [
#     {
#       from_port = 3000
#       to_port = 3000
#       protocol = "tcp"
#       cidr_blocks = "0.0.0.0/0"
#     }
#   ]

#   egress_rules = ["all-all"]
# }


#output

output "ec2_public_ip" {
  value = "ssh -i ~/.ssh/terraform_ec2.pem ubuntu@${aws_instance.tf_ec2_instance1.public_ip}"
}