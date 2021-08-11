/*
./terraformDocker.sh destroy -auto-approve && ./terraformDocker.sh apply -var-file="secrets.tfvars" -auto-approve
./terraformDocker.sh apply -var-file="secrets.tfvars" -auto-approve
./terraformDocker.sh destroy -auto-approve
# CRC and SNC
sudo journalctl -u google-startup-scripts.service -f
# CRC
sudo journalctl -u crc.service -f
sudo tail -f /var/log/messages -n +1 | grep runuser
sudo cat /var/log/messages | grep runuser
# SNC
tail -f /home/crcuser/snc/install.out
*/


data "template_file" "default" {
  template = file("${path.module}/init.tpl")
  vars = {
    file_inadyn_conf = data.template_file.inadyn_conf.rendered
    file_provision_yml = base64encode(data.template_file.provision_yml.rendered)
    file_ddns_j2 = file("${path.module}/ddns.j2")
    file_crc_j2 = file("${path.module}/crc.j2")
    file_banner = file("${path.module}/banner.txt")
    file_tools_sh = file("${path.module}/tools.sh")
    strategy = var.strategy
  }
}

data "template_file" "inadyn_conf" {
  template = file("${path.module}/inadyn.conf")
  vars = {
    ddns_provider = var.ddns_provider
    ddns_login = var.ddns_login
    ddns_password = var.ddns_password
    ddns_hostname = var.ddns_hostname
  }
}

data "template_file" "provision_yml" {
  template = file("${path.module}/provision.yml")
  vars = {
    ddns_enabled = var.ddns_enabled
    docker_login = var.docker_login
    docker_password = var.docker_password
    strategy: var.strategy
    crc_pull_secret = file("${path.module}/pull-secret.txt")
    crc_snc_memory = var.crc_snc_memory
    crc_snc_cpus = var.crc_snc_cpus
    snc_disk_size = var.snc_disk_size
    crc_monitoring_enabled = var.crc_monitoring_enabled
  }
}

resource "google_compute_disk" "crcdisk" {
  name  = var.disk-name
  type  = "pd-standard"
  zone  = var.zone
  image = var.image

  timeouts {
    create = "60m"
  }
}

resource "google_compute_image" "crcimg" {
  name = "my-centos-8"
  source_disk = google_compute_disk.crcdisk.self_link
  licenses = [
    "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx",
  ]
  timeouts {
    create = "60m"
  }
}

resource "google_compute_instance" "crc-build-box" {
  count = var.vmcount
  name = "${var.instance-name}-${count.index + 1}"
  machine_type = var.gcp_vm_type

  zone = var.zone

  #min_cpu_platform = "Intel Haswell"

  tags = [
    "default-firewall-ssh",
    "default-firewall-http",
    "default-firewall-https",
    "default-firewall-icmp",
    "default-firewall-openshift-console",
    "default-firewall-secure-forward",
  ]
  
  scheduling {
    automatic_restart = false
    preemptible = var.gcp_vm_preemptible
  }

  advanced_machine_config {
    enable_nested_virtualization = true
  }

  boot_disk {
    initialize_params {
      image = var.image
      type  = var.gcp_vm_disk_type
      size  = var.gcp_vm_disk_size
    }
  }

  metadata = {
    ssh-keys = "crcuser:${file("crcuser_key.pub")}"
  }
  
  metadata_startup_script = data.template_file.default.rendered

  network_interface {
    #subnetwork = "${google_compute_subnetwork.crc_network_subnetwork.name}"
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
  timeouts {
  create = "60m"
  }
}

resource "google_compute_project_default_network_tier" "default" {
  network_tier = "STANDARD"
}
