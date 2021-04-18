/*
terraform destroy -auto-approve && terraform apply -var-file="secrets.tfvars" -auto-approve
terraform apply -var-file="secrets.tfvars" -var="project_id=$TF_VAR_PROJECT_ID" -auto-approve
terraform destroy -auto-approve
sudo journalctl -u google-startup-scripts.service -f
sudo journalctl -u crc.service -f
sudo tail -f /var/log/messages -n +1 | grep runuser
sudo cat /var/log/messages | grep runuser
*/


resource "google_compute_disk" "crcdisk" {
  name  = "${var.disk-name}"
  type  = "pd-standard"
  zone  = "${var.region}"
  image = "${var.os}"

  timeouts {
  create = "60m"
  }
}

resource "google_compute_image" "crcimg" {
  name = "${var.image-name}"
  source_disk = "${google_compute_disk.crcdisk.self_link}"
  licenses = [
    "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx",
  ]
  timeouts {
  create = "60m"
  }
}

data "template_file" "default" {
  template = "${file("${path.module}/init.tpl")}"
  vars = {
    ddns_enabled = "${var.ddns_enabled}"
    ddns_login = "${var.ddns_login}"
    ddns_password = "${var.ddns_password}"
    ddns_hostname = "${var.ddns_hostname}"
    docker_login = "${var.docker_login}"
    docker_password = "${var.docker_password}"
    crc_pull_secret = "${file("${path.module}/pull-secret.txt")}"
  }
}

resource "google_compute_instance" "crc-build-box" {
  count = "${var.vmcount}"
  name = "${var.instance-name}-${count.index + 1}"
  machine_type = "${var.vm_type}"

  zone = "${var.region}"

  #min_cpu_platform = "Intel Haswell"

  tags = [
    "${var.network}-firewall-ssh",
    "${var.network}-firewall-http",
    "${var.network}-firewall-https",
    "${var.network}-firewall-icmp",
    "${var.network}-firewall-openshift-console",
    "${var.network}-firewall-secure-forward",
  ]
  
  scheduling {
    automatic_restart = false
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image = "${google_compute_image.crcimg.self_link}"
      type  = "pd-standard"
      size  = "${var.disk-size}"
    }
  }
  
  #hostname = "${var.instance-name}"
  #metadata {
  #  hostname = "${var.instance-name}"
  #}
  
  metadata_startup_script = "${data.template_file.default.rendered}"

  network_interface {
    subnetwork = "${google_compute_subnetwork.crc_network_subnetwork.name}"

    access_config {
      // Ephemeral IP
    }
  }
  timeouts {
  create = "60m"
  }
}
