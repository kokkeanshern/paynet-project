resource "aws_s3_bucket" "airflow-assets" {
  bucket = "my-airflow-assets"

  tags = {
    Name = "airflow-assets"
  }
}

resource "aws_s3_object" "docker-compose" {
  bucket = aws_s3_bucket.airflow-assets.id
  key    = "docker-compose.yaml"
  source = "docker-compose.yaml"
  etag   = filemd5("docker-compose.yaml")
}
