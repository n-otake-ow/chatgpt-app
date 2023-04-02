locals {
  app = {
    name = "chatgpt-app"
  }

  cloud_run = {
    image_name = "app"
    image_tag  = "latest"
  }
}
