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
  ami                    = "ami-08569b978cc4dfa10" # Public Linux
  instance_type          = "t2.micro"
  key_name = aws_key_pair.airflow-ec2-key-pair.key_name
  subnet_id              = data.aws_subnet.paynet-project-public-subnet.id
  vpc_security_group_ids = [data.aws_security_group.allow_ssh_http.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # user_data = <<-EOF
  #             #!/bin/bash
  #             aws s3 cp s3://my-airflow-assets/docker-compose.yaml ./docker-compose.yaml
  #             mkdir ./dags ./logs ./plugins
  #             echo -e "AIRFLOW_UID=$(id -u)\nAIRFLOW_GID=0" > .env
  #             sudo yum update -y
  #             sudo yum install -y docker
  #             mkdir -p ~/.docker/cli-plugins/
  #             curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
  #             chmod +x ~/.docker/cli-plugins/docker-compose

  #             sudo service docker start
  #             sudo usermod -aG docker ec2-user
  #             docker compose up airflow-init
  #             docker compose up
  #             EOF

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Install Docker and curl
              yum update -y
              yum install -y docker curl

              # Start Docker
              service docker start
              chkconfig docker on

              # Add ec2-user to docker group
              usermod -aG docker ec2-user

              # Install Docker Compose v2 (plugin method)
              mkdir -p /home/ec2-user/.docker/cli-plugins/
              curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
                -o /home/ec2-user/.docker/cli-plugins/docker-compose
              chmod +x /home/ec2-user/.docker/cli-plugins/docker-compose
              chown -R ec2-user:ec2-user /home/ec2-user/.docker

              # Create Airflow directories
              mkdir -p /home/ec2-user/dags /home/ec2-user/logs /home/ec2-user/plugins
              chown -R ec2-user:ec2-user /home/ec2-user

              # Switch to ec2-user for the next steps
              su - ec2-user -c "
                # Download Docker Compose file from S3
                aws s3 cp s3://my-airflow-assets/docker-compose.yaml /home/ec2-user/docker-compose.yaml

                # Create .env file for Airflow UID
                echo -e 'AIRFLOW_UID=50000\nAIRFLOW_GID=0' > /home/ec2-user/.env

                # Start Airflow containers
                docker compose -f /home/ec2-user/docker-compose.yaml up airflow-init
                docker compose -f /home/ec2-user/docker-compose.yaml up -d
              "
            EOF
  
  depends_on = [
    aws_s3_object.docker-compose

  ]

  tags = {
    Name = "AirflowInstance"
  }
}
