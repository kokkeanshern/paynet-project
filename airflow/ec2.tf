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
  subnet_id              = data.aws_subnet.paynet-project-public-subnet.id
  vpc_security_group_ids = [data.aws_security_group.allow_ssh_http.id]

  user_data = <<-EOF
              #!/bin/bash
              aws s3 cp s3://my-airflow-assets/docker-compose.yaml ./docker-compose.yaml
              mkdir ./dags ./logs ./plugins
              echo -e "AIRFLOW_UID=$(id -u)\nAIRFLOW_GID=0" > .env
              docker-compose up airflow-init
              docker-compose up
              EOF
  
  depends_on = [
    aws_s3_object.docker-compose
  ]

  tags = {
    Name = "AirflowInstance"
  }
}
