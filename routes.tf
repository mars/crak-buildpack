# Default routing for mars/crak buildpack.
#
# This Terraform config my be copied into the app and customized.

resource "kong_service" "react" {
  name     = "create-react-app"
  protocol = "http"
  host     = "127.0.0.1"
  port     = 3000
}

resource "kong_route" "web_root" {
  protocols  = ["https", "http"]
  paths      = ["/"]
  service_id = "${kong_service.react.id}"
}
