resource "google_compute_firewall" "ssh" {
  name    = "default-firewall-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["default-firewall-ssh"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp" {
  name    = "default-firewall-icmp"
  network = "default"

  allow {
    protocol = "icmp"
  }

  target_tags   = ["default-firewall-icmp"]
  source_ranges = ["0.0.0.0/0"]
}