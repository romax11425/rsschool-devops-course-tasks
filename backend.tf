terraform {
  backend "s3" {
    bucket       = "rss-tf-state"
    key          = "rss/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
