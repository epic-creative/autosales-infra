# main.tf
terraform {
  required_providers {
    fly = {
      source = "fly-apps/fly"
      version = "0.0.16"
    }
  }
}

resource "fly_app" "exampleApp" {
  name = "flyiac" #Replace this with your own app name
  org  = "personal"
}

resource "fly_ip" "exampleIp" {
  app        = "flyiac" #Replace this with your own app name
  type       = "v4"
  depends_on = [fly_app.exampleApp]
}

resource "fly_ip" "exampleIpv6" {
  app        = "flyiac" #Replace this with your own app name
  type       = "v6"
  depends_on = [fly_app.exampleApp]
}

resource "fly_machine" "exampleMachine" {
  for_each = toset(["ewr", "lax"])
  app    = "flyiac" #Replace this with your own app name
  region = each.value
  name   = "flyiac-${each.value}"
  image  = "flyio/iac-tutorial:latest"
  services = [
    {
      ports = [
        {
          port     = 443
          handlers = ["tls", "http"]
        },
        {
          port     = 80
          handlers = ["http"]
        }
      ]
      "protocol" : "tcp",
      "internal_port" : 80
    },
  ]
  cpus = 1
  memorymb = 256
  depends_on = [fly_app.exampleApp]
}