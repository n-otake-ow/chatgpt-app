# Terraform Directory

This directory contains Terraform code for provisioning infrastructure on Google Cloud.

## Prerequisites

Before running Terraform, you will need:

- Terraform installed on your local machine.
- A Google Cloud project and a service account with the necessary permissions to manage resources.
- Set up authentication with Google Cloud using Application Default Credentials or a service account key file.

## Usage

1. Initialize Terraform:

```sh
terraform init \
  -backend-config="bucket=yourbucket" \
  -backend-config="prefix=path/to/terraform.tfstate" \
  -backend-config="credentials=./credentials/yourcreds.json"
```

2. Add the credential file for the Google Cloud service account used by Terraform to the `.credentials` directory.

3. Create a terraform.tfvars file to provide input variables for your project:

```sh
cp terraform.tfvars.tpl terraform.tfvars
```

4. Update the values in terraform.tfvars to match your project and desired configuration.

5. Preview the changes that Terraform will make:

```sh
terraform plan -target=google_artifact_registry_repository.this
```

6. Apply the changes:

```sh
terraform apply -target=google_artifact_registry_repository.this
```

7. Build and push the application image to GAR:

```sh
cd ../app
make build && make push
```

8. Preview the changes that Terraform will make:

```sh
terraform plan
```

9. Apply the changes:

```sh
terraform apply
```

10. Make changes to the code and repeat steps 8 and 9

11. To destroy the resources:

```sh
terraform destroy
```
