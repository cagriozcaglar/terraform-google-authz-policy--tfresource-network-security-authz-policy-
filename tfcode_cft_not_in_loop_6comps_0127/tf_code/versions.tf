# The versions.tf file is used to specify the required Terraform version and provider requirements.
terraform {
  # Specifies the minimum required version of Terraform to run this module.
  required_version = ">= 1.3.0"
  required_providers {
    # The google-beta provider is used to manage Google Cloud Platform resources.
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.3.0"
    }
    # The random provider is used to generate random values.
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
