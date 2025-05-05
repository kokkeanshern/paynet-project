resource "aws_iam_role" "ec2_s3_read_role" {
  name = "airflow-ec2-s3-read-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "s3_read_access" {
  name        = "airflow-s3-read-access"
  description = "Allow EC2 to read from my-airflow-assets bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject"],
      Resource = "arn:aws:s3:::my-airflow-assets/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_read_role.name
  policy_arn = aws_iam_policy.s3_read_access.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "airflow-ec2-profile"
  role = aws_iam_role.ec2_s3_read_role.name
}
