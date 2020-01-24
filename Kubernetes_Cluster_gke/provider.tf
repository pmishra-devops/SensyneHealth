provider "google" {
  credentials = "${local.service_account_path}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

# Location to store remote state
# terraform {
#   backend "gcs" {
#     bucket  = "dev-state"
#     credentials = "${file("~/.gcloud/service_account_keys/.json")}"
#     prefix  = "dev"
#   }
# }

# Location to retrieve remote state
data "terraform_remote_state" "remote_state" {
  backend = "gcs"
  config = {
    bucket  = "${var.bucket_name}"
    credentials = "${local.service_account_path}"
    prefix  = "${local.bucket_prefix}"
  }
}

locals {
  service_account_path = "${file("${var.service_account_file_basepath}${var.project_id}.json")}"
  # GCS prefix inside the bucket. Named states for workspaces are stored in an object called <prefix>/<name>.tfstate.
  bucket_prefix = "${var.env}"
}
