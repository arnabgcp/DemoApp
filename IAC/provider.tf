terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.9.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-backend-ardent-case-441007-d8"
  }
}