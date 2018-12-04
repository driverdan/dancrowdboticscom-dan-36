resource "heroku_app" "production" {
  name   = "${var.app_name}-prod"
  region = "us"

  buildpacks = [
    "heroku/python"
  ]

  config_vars = {
    DEBUG_COLLECTSTATIC = "1"
  }
}

resource "heroku_addon" "database_production" {
  app  = "${heroku_app.production.id}"
  plan = "heroku-postgresql:hobby-dev"
}

resource "heroku_addon" "sendgrid_production" {
  app  = "${heroku_app.production.id}"
  plan = "sendgrid:starter"
}

resource "heroku_app" "staging" {
  name   = "${var.app_name}-staging"
  region = "us"

  buildpacks = [
    "heroku/python"
  ]

  config_vars = {
    DEBUG_COLLECTSTATIC = "1"
  }
}

resource "heroku_addon" "database_staging" {
  app  = "${heroku_app.staging.id}"
  plan = "heroku-postgresql:hobby-dev"
}

resource "heroku_addon" "sendgrid_staging" {
  app  = "${heroku_app.staging.id}"
  plan = "sendgrid:starter"
}

resource "heroku_domain" "cb_domain" {
  app      = "${heroku_app.production.id}"
  hostname = "${var.app_name}.botics.co"
}

resource "cloudflare_record" "cb_domain_record" {
  domain = "botics.co"
  name   = "${var.app_name}"
  value  = "${heroku_domain.cb_domain.cname}"
  type   = "CNAME"
  // ttl of 1 is automatic
  ttl    = 1
}
/*
resource "heroku_domain" "custom_domain" {
  app      = "${heroku_app.production.id}"
  hostname = "${var.custom_domain}"
}
*/
resource "heroku_pipeline" "pipeline" {
  name = "${var.app_name}"
}

resource "heroku_pipeline_coupling" "production" {
  app      = "${heroku_app.production.name}"
  pipeline = "${heroku_pipeline.pipeline.id}"
  stage    = "production"
}

resource "heroku_pipeline_coupling" "staging" {
  app      = "${heroku_app.staging.name}"
  pipeline = "${heroku_pipeline.pipeline.id}"
  stage    = "staging"
}

output "app_id" {
  value = "${heroku_app.production.id}"
}
output "app_name" {
  value = "${heroku_app.production.name}"
}
output "web_url" {
  value = "${heroku_app.production.web_url}"
}
