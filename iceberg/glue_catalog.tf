resource "aws_glue_catalog_database" "iceberg-bronze-db" {
  name = "iceberg-bronze-db"
}

resource "aws_glue_catalog_database" "iceberg-silver-db" {
  name = "iceberg-silver-db"
}

resource "aws_glue_catalog_database" "iceberg-gold-db" {
  name = "iceberg-gold-db"
}
