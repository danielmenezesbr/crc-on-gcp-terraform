/*
export TF_VAR_PROJECT_ID=$(gcloud projects list --filter='name:CRConGCP' --format='value(project_id)' --limit=1)
export PATH=~:$PATH
terraform destroy -auto-approve && terraform apply -var-file="secrets.tfvars" -var="project_id=$TF_VAR_PROJECT_ID" -auto-approve
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
    file_inadyn_conf = "${data.template_file.inadyn_conf.rendered}"
    file_aut_yml = "${data.template_file.aut_yml.rendered}"
    file_myservice_j2 = "${file("${path.module}/myservice.j2")}"
    file_crc_j2 = "${file("${path.module}/crc.j2")}"
  }
}

data "template_file" "inadyn_conf" {
  template = "${file("${path.module}/inadyn.conf")}"
  vars = {
    ddns_login = "${var.ddns_login}"
    ddns_password = "${var.ddns_password}"
    ddns_hostname = "${var.ddns_hostname}"
  }
}

data "template_file" "aut_yml" {
  template = "${file("${path.module}/aut.yml")}"
  vars = {
    ddns_enabled = "${var.ddns_enabled}"
    docker_login = "${var.docker_login}"
    docker_password = "${var.docker_password}"
    crc_enabled: "${var.crc_enabled}"
    snc_enabled: "${var.snc_enabled}"
    crc_pull_secret = "${file("${path.module}/pull-secret.txt")}"
    crc_snc_memory = "${var.crc_snc_memory}"
    crc_snc_cpus = "${var.crc_snc_cpus}"
    snc_disk_size = "${var.snc_disk_size}"
    crc_monitoring_enabled = "${var.crc_monitoring_enabled}"
  }
}

resource "google_compute_instance" "crc-build-box" {
  count = var.vmcount
  name = "${var.instance-name}-${count.index + 1}"
  machine_type = var.gcp_vm_type

  zone = var.region

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
    preemptible = var.gcp_vm_preemptible
  }

  boot_disk {
    initialize_params {
      image = "${google_compute_image.crcimg.self_link}"
      type  = var.gcp_vm_disk_type
      size  = var.gcp_vm_disk_size
    }
  }

  metadata = {
    ssh-keys = "crcuser:${file("crcuser_key.pub")}"
  }
  
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
