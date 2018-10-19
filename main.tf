# Default Terraform backend & provider for mars/crak buildpack.
#
# This Terraform config my be copied into the app and customized.
#
# The "pg" backend is configured & initialized at runtime
# via [heroku-buildpack-crak-release](bin/app/heroku-buildpack-crak-release).

terraform {
  backend "pg" {}
}

provider "kong" {
  version        = "~> 1.7"
  kong_admin_uri = "http://127.0.0.1:8001"
}
