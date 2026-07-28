provider "google" {
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "demo_bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  storage_class = var.gcs_storage_class

  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = var.bq_dataset_name
  project    = var.project
  location   = var.location
}