variable "region" {
  default = "us-central1-a"
}

variable "project-name" {
  default = "crc-on-gcp"
}

variable "vmcount" {
  default = "1"
}

variable "instance-name" {
  default = "vagrant-build"
}

variable "subnetwork-region" {
  default = "us-central1"
}

variable "network" {
  default = "vagrant-network"
}

variable "vm_type" {
  default = "n1-standard-8"
}

variable "os" {
  default = "centos-8-v20210122"
}

variable "image-name" {
  default = "vagrantimg"
}

variable "disk-name" {
  default = "vagrantdisk"
}

variable "disk-size" {
  default = "50"
}

variable "ddns_enabled" {
  default = "true"
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

variable "docker_password" {
  default = ""
}

variable "ddns_password" {
  default = ""
}

variable "crc_pull_secret" {
  default = ""
}