terraform {
  required_version = "~> 1.4.0"

  backend "gcs" {
    # run below command to configure backend
    # $ terraform init \
    #   -backend-config="bucket=yourbucket" \
    #   -backend-config="prefix=path/to/terraform.tfstate" \
    #   -backend-config="credentials=./credentials/yourcreds.json"
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
