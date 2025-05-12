resource "aws_s3_bucket" "iceberg-bronze-bucket" {
    bucket  = "iceberg-bronze-bucket"
}
resource "aws_s3_bucket" "iceberg-silver-bucket" {
    bucket  = "iceberg-silver-bucket"
}
resource "aws_s3_bucket" "iceberg-gold-bucket" {
    bucket  = "iceberg-gold-bucket"
}
