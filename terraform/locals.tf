locals {
  app = {
    name = "chatgpt-app"
  }

  envvars = [
    {
      name  = "GCLOUD_PROJECT"
      value = var.project_id
    },
  ]

  secrets = [
    {
      name  = "${local.app.name}__OPENAI_API_KEY"
      value = var.openai_api_key
    },
  ]

  cloud_run = {
    image_name = "app"
    image_tag  = "latest"
  }
}
