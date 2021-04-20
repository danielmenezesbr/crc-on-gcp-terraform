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

variable "crc_memory" {
  default = "20000"
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