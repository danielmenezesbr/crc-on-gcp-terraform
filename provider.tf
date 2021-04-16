provider "google" {
  credentials = "${file("${path.module}/terraform.json")}"
  project     = "${var.project-name}"
  region      = "${var.region}"
}
