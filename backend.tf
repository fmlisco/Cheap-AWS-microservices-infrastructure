terraform {
  backend "s3" {
    bucket  = "lisco-remote-state-s3"
    key     = "vuitest.tfstate"
    region  = "us-east-1"
    encrypt = "true"
    dynamodb_table = "vuitest-dynamodb"
  }
}