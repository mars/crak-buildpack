terraform {
  backend "pg" {}
}

provider "kong" {
  version        = "~> 1.7"
  kong_admin_uri = "http://127.0.0.1:8001"
}
