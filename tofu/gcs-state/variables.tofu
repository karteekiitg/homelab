# Define a variable for the Google Cloud project ID
variable "gcp_project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
}
# Define a variable for the Google Cloud region
variable "gcp_region" {
  description = "The Google Cloud region to deploy resources into."
  type        = string
}

# Define a variable for the GCS bucket name
variable "bucket_name" {
  description = "The globally unique name for the GCS bucket."
  type        = string
}

variable "tofu_encryption_passphrase" {
  description = "The encryption passphrase for tofu state encryption."
  type        = string
  sensitive   = true
}

variable "gcp_sa_dev_emails" {
  description = "GCP SA Dev emails"
  type        = string
}
