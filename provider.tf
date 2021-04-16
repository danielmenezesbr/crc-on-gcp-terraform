provider "google" {
  credentials = "${file("${path.module}/terraform.key.json")}"
  project     = "${var.project-name}"
  region      = "${var.region}"
}
