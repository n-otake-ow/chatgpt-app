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
  -backend-config="key=path/to/terraform.tfstate" \
  -backend-config="region=your-bucket-region" \
  -backend-config="encrypt=true"
```

1. Add the credential file for the Google Cloud service account used by Terraform to the `.credentials` directory.

2. Create a terraform.tfvars file to provide input variables for your project:

```sh
cp terraform.tfvars.tpl terraform.tfvars
```

1. Update the values in terraform.tfvars to match your project and desired configuration.

1. Preview the changes that Terraform will make:

```sh
terraform plan
```

1. Apply the changes:

```sh
terraform apply
```

Note: Terraform will prompt you to confirm the changes before applying them.

1. To destroy the resources:

```sh
terraform destroy
```

Note: Terraform will prompt you to confirm the destruction of resources before proceeding.
