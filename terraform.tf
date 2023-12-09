provider "google" {
  project = var.project
  alias   = "tokengen"
}

data "google_service_account_access_token" "sa" {
  provider               = google.tokengen
  target_service_account = "iac-sa@${var.project}.iam.gserviceaccount.com"
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "3600s"
}

terraform {
  required_version = "~> 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
  }
}

provider "google" {
  project      = var.project
  region       = var.region
  zone         = var.zone
  access_token = data.google_service_account_access_token.sa.access_token
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}


resource "google_project_service" "container" {
  service = "container.googleapis.com"
}
