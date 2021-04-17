provider "google" {
  credentials = "${file("${path.module}/terraform.key.json")}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}
