terraform {
  /*  cloud {
    organization = "FlexPay-Tutorials"
    workspaces {
      name = "learn-terraform-ansible"
    }
  }
*/
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1"
    }
  }

  required_version = ">= 1.2.0"
}
