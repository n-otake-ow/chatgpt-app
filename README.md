# chatgpt-app

**This is a repository I created as a hobby project. I cannot take responsibility for any issues caused by the applications created from this repository.**

![demo](images/demo.gif)

This project contains the infrastructure code in `terraform/` directory and the application code in `app/` directory.

## Terraform

1. Switch to the `terraform/` directory: `cd terraform`
1. Initialize the working directory: `terraform init`
1. Apply the configuration: `terraform apply`

## Application

1. Move to the `app/` directory: `cd app`
1. Build the container: `make build`
1. Push the container to Google Container Registry: `make push`
   - Note: You may need to execute gcloud `auth configure-docker REGION-docker.pkg.dev` command before pushing the container. Replace REGION with the region you are using.
1. Deploy the container to Cloud Run: `make deploy`

## Local Development

1. Move to the `app/` directory: `cd app`
1. Run the local docker-compose environment: `make up`
1. Develop the application
1. Stop the local environment: `make down`
