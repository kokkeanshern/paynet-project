data "aws_vpc" "paynet-project-vpc" {
  filter {
    name   = "tag:Name"
    values = ["paynet-project-vpc"]
  }
}

data "aws_subnet" "paynet-project-public-subnet" {
  filter {
    name   = "tag:Name"
    values = ["paynet-project-public-subnet"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.paynet-project-vpc.id]  # Ensure VPC data block is defined
  }
}

data "aws_security_group" "allow_ssh_http" {
  filter {
    name   = "group-name"
    values = ["allow_ssh_http"]
  }

  vpc_id = data.aws_vpc.paynet-project-vpc.id  # Or hardcoded if you prefer
}

resource "aws_instance" "airflow_instance" {
  ami                    = "ami-05928b89ce5ea0cf5"
  instance_type          = "m7g.large"
  key_name = aws_key_pair.airflow-ec2-key-pair.key_name
  subnet_id              = data.aws_subnet.paynet-project-public-subnet.id
  vpc_security_group_ids = [data.aws_security_group.allow_ssh_http.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = 0.0477
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              yum -y install python-pip
              service docker start

              curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              mkdir -p /home/ec2-user/dags /home/ec2-user/logs /home/ec2-user/config /home/ec2-user/plugins
              cd /home/ec2-user
              aws s3 cp s3://my-airflow-assets/docker-compose.yaml docker-compose.yaml
              echo -e "AIRFLOW_UID=$(id -u ec2-user)\nAIRFLOW_GID=0" > .env
              chown ec2-user:ec2-user .env docker-compose.yaml dags logs plugins

              runuser -l ec2-user -c "sudo docker compose run airflow-cli airflow config list"
              runuser -l ec2-user -c "sudo docker-compose up airflow-init"
              runuser -l ec2-user -c "sudo docker-compose up -d"
              EOF

  depends_on = [
    aws_s3_object.docker-compose

  ]

  tags = {
    Name = "AirflowInstance"
  }
}
