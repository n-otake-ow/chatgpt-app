locals {
  app = {
    name = "chatgpt-app"
  }

  secrets = [
    {
      name  = "OPENAI_API_KEY"
      value = var.openai_api_key
    },
  ]

  cloud_run = {
    image_name = "app"
    image_tag  = "latest"
  }
}
