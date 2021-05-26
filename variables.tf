variable "crc_enabled" {
  default = "true"
}

variable "snc_enabled" {
  default = "false"
}

variable "region" {
  default = "us-central1-a"
}

variable "project_id" {
  default = ""
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

variable "vm_type" {
  default = "n1-standard-8"
}

variable "os" {
  default = "centos-8-v20210122"
}

variable "image-name" {
  default = "crcimg"
}

variable "disk-name" {
  default = "crcdisk"
}

variable "disk-size" {
  default = "50"
}

variable "ddns_enabled" {
  default = "false"
}

variable "ddns_login" {
  default = "bytecodesbr"
}

variable "ddns_hostname" {
  default = "crc-openshift.ignorelist.com"
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