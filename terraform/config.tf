terraform {
  required_version = "~> 1.4.0"

  backend "s3" {
    # run below command to configure backend
    # $ terraform init \
    #   -backend-config="bucket=yourbucket" \
    #   -backend-config="key=path/to/terraform.tfstate" \
    #   -backend-config="region=ap-northeast-1" \
    #   -backend-config="encrypt=true"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project_id
  region      = var.location
}
