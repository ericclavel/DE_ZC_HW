variable "project" {
  description = "GCP project ID"
  type        = string
  default     = "arctic-operand-398220"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-west1"
}

variable "location" {
  description = "GCP resource location"
  type        = string
  default     = "us-west1"
}

variable "bq_dataset_name" {
  description = "BigQuery dataset name"
  type        = string
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "Google Cloud Storage bucket name"
  type        = string
  default = "arctic-operand-398220-eclavel-hw"
}

variable "gcs_storage_class" {
  description = "Google Cloud Storage class"
  type        = string
  default     = "STANDARD"
}