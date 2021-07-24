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

resource "google_compute_firewall" "http" {
  name    = "default-firewall-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["default-firewall-http"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "https" {
  name    = "default-firewall-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags   = ["default-firewall-https"]
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

resource "google_compute_firewall" "firewall-openshift-console" {
  name    = "default-firewall-openshift-console"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_tags   = ["default-firewall-openshift-console"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall-secure-forward" {
  name    = "default-firewall-secure-forward"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["24284"]
  }

  target_tags   = ["default-firewall-secure-forward"]
  source_ranges = ["0.0.0.0/0"]
}
