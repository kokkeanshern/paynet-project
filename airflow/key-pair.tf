resource "aws_key_pair" "airflow-ec2-key-pair" {
  key_name   = "airflow-ec2-key-pair"
  public_key = file("./keys/paynet-airflow-ec2-ecdsa.pub")
}
