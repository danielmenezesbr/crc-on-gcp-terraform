variable "crc_enabled" {
  default = "true"
}

variable "snc_enabled" {
  default = "false"
}

variable "gcp_vm_preemptible" {
  default = "true"
}

variable "gcp_vm_type" {
  default = "n1-standard-8"
}

variable "gcp_vm_disk_type" {
  default = "pd-standard"
  description = "pd-standard or pd-ssd"
}

variable "region" {
  default = "us-central1-a"
}

variable "project_id" {
  default = ""
  validation {
    condition = (
    length(var.project_id) > 0
    )
    error_message = "The project_id is required."
  }
}

variable "vmcount" {
  default = "1"
}

variable "instance-name" {
  default = "crc-build"
}

variable "subnetwork-region" {
  default = "us-central1"
}

variable "network" {
  default = "crc-network"
}

variable "image" {
  default = "projects/okd4-280016/global/images/packer-1597358211"
}

variable "disk-name" {
  default = "crcdisk"
}

variable "gcp_vm_disk_size" {
  default = "128"
}

variable "ddns_enabled" {
  default = "false"
}

variable "ddns_provider" {
  default = "duckdns.org"
  description = "freedns.afraid.org, duckdns.org etc."
/*
https://fossies.org/linux/inadyn/README.md

Examples:
provider duckdns.org {
    username         = YOUR_TOKEN
    password         = noPasswordForDuckdns
    hostname         = YOUR_DOMAIN.duckdns.org
}

provider freedns {
    username    = lower-case-username
    password    = case-sensitive-pwd
    hostname    = some.example.com
}
*/
}


variable "ddns_login" {
  default = ""
  description = "duckdns.org uses this field to put TOKEN. In this case, put it in secrets.tfvars because TOKEN is a sensitive data."
}

variable "ddns_hostname" {
  default = "myopenshift.duckdns.org"
}

variable "docker_login" {
  default = "danielmenezesbr"
}

variable "crc_snc_memory" {
  default = "20000"
}

variable "crc_snc_cpus" {
  default = "7"
}

variable "snc_disk_size" {
  default = "33285996544" # 31 GiB
  description = "disk size"
}

variable "crc_monitoring_enabled" {
  default = "false"
}

variable "docker_password" {
  default = ""
}

variable "ddns_password" {
  default = ""
}

locals {
  validate_fet_code_cnd = var.crc_enabled == var.snc_enabled
  validate_fet_code_msg = "Error. crc_enabled and snc_enabled have the same value."
  validate_fet_code_chk = regex(
      "^${local.validate_fet_code_msg}$",
      ( !local.validate_fet_code_cnd
        ? local.validate_fet_code_msg
        : "" ) )
}