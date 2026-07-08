terraform {
  required_version = ">= 1.5.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0, < 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27.0, < 3.0.0"
    }
  }

  # Remote state backend. Configure per environment with a partial backend
  # config file (see terraform/environments/<env>/backend.hcl) and run:
  #   terraform init -backend-config=environments/<env>/backend.hcl
  #
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "service-mesh-istio-platform/terraform.tfstate"
  #   region = "us-east-1"
  # }
}
