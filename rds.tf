
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "my_demo"
  identifier           = "nodejs-rds-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "massy123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = true
  vpc_security_group_ids = [aws_security_group.tf_rds_sg_1.id]
}



resource "aws_security_group" "tf_rds_sg_1" {
  name        = "allow_mysql"
  description = "Allow mysql traffic"
  vpc_id      = "vpc-03c63f57c5c371095"

}

resource "aws_security_group_rule" "rds_from_ec2" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  //security_group_id = aws_security_group.tf_ec2_sg.id
   security_group_id        = aws_security_group.tf_rds_sg_1.id   # RDS SG
  source_security_group_id =   aws_security_group.tf_ec2_sg.id  
  
}


resource "aws_security_group_rule" "rds_from_home" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["49.37.178.72/32"]              #["0.0.0.0/0"]
  //security_group_id = aws_security_group.tf_ec2_sg.id
   security_group_id        = aws_security_group.tf_rds_sg_1.id   # RDS SG
  
}


resource "aws_security_group_rule" "rds_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_rds_sg_1.id
}

#locals
locals {
  rds_endpoint = element(split(":", aws_db_instance.default.endpoint), 0)
}

#outputs
output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "rds_username" {
  value = aws_db_instance.default.username
}

output "rds_db_name" {
  value = aws_db_instance.default.db_name
}