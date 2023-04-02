locals {
  app = {
    name = "chatgpt-app"
  }

  secrets = [
    {
      name  = "openai_api_key"
      value = var.openai_api_key
    },
  ]

  cloud_run = {
    image_name = "app"
    image_tag  = "latest"
  }
}
