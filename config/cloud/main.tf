provider "aws" {
    region = var.myRegion
}

resource "aws_iam_role" "ec2_cloudwatch_role" {
    name = "EC2CloudWatchPutMetricRole"
    assume_role_policy = jsonencode({
                            "Version": "2012-10-17",
                            "Statement": [
                              {
                                "Action": "sts:AssumeRole",
                                "Principal": {
                                  "Service": "ec2.amazonaws.com"
                                },
                                "Effect": "Allow",
                                "Sid": ""
                              }
                            ]
                          })
}

resource "aws_iam_role_policy" "ec2_cloudwatch_policy" {
    name = "EC2CloudWatchPutMetricPolicy"
    role = aws_iam_role.ec2_cloudwatch_role.id
    policy = jsonencode({
                            "Version": "2012-10-17",
                            "Statement": [
                              {
                                "Action": [
                                  "cloudwatch:PutMetricData"
                                ],
                                "Effect": "Allow",
                                "Resource": "*"
                              }
                            ]
                          })
}

resource "aws_iam_instance_profile" "ec2_cloudwatch_profile" {
    name = "EC2CloudWatchPutMetricProfile"
    role = aws_iam_role.ec2_cloudwatch_role.name
}

resource "aws_instance" "nginx_server" {
  availability_zone = "${var.myRegion}a"
  instance_type = "t2.micro"
  ami = "ami-0ddc798b3f1a5117e"
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_cloudwatch_profile.name
  key_name = "KeyPairEC2Ngnix1"
  user_data = <<-EOF
              #!/bin/bash
              export AWS_DEFAULT_REGION=${var.myRegion}
              sudo yum update -y
              sudo amazon-linux-extras install -y nginx1
              sudo systemctl start nginx
              sudo systemctl enable nginx

              ${file("${path.module}/scripts/memory_monitor.sh")}
              EOF
  tags = {
    Name = "Nginx Server"
  }
}

resource "aws_instance" "tomcat_server" {
  availability_zone = "${var.myRegion}a"
  instance_type = "t2.micro"
  ami = "ami-0ddc798b3f1a5117e"
  associate_public_ip_address = true
  key_name = "KeyPairEC2Ngnix1"
  iam_instance_profile = aws_iam_instance_profile.ec2_cloudwatch_profile.name
  user_data = <<-EOF
              #!/bin/bash
              export AWS_DEFAULT_REGION=${var.myRegion}
              sudo yum update -y
              sudo amazon-linux-extras install java-openjdk11 -y
              cd /opt
              sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.76/bin/apache-tomcat-9.0.76.tar.gz
              sudo tar -xvzf apache-tomcat-9.0.76.tar.gz 
              sudo ln -s apache-tomcat-9.0.76 tomcat
              sudo chmod +x /opt/tomcat/bin/*.sh
              sudo bash -c 'cat > /etc/systemd/system/tomcat.service' <<EOL
              [Unit]
              Description=Apache Tomcat Web Application Container
              After=network.target
              
              [Service]
              Type=forking

              Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
              Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
              Environment=CATALINA_HOME=/opt/tomcat
              Environment=CATALINA_BASE=/opt/tomcat

              ExecStart=/opt/tomcat/bin/startup.sh
              ExecStop=/opt/tomcat/bin/shutdown.sh
              
              User=ec2-user
              Group=ec2-users
              UMask=0007
              RestartSec=10
              Restart=always

              [Install]
              WantedBy=multi-user.target
              EOL
              sudo systemctl daemon-reload
              sudo systemctl start tomcat
              sudo systemctl enable tomcat

              ${file("${path.module}/scripts/memory_monitor.sh")}
              EOF
  tags = {
    Name = "Tomcat Server"
  }
}

output "nginx_server_public_ip" {
  value = aws_instance.nginx_server.public_ip
}

output "tomcat_server_public_ip" {
  value = aws_instance.tomcat_server.public_ip
}