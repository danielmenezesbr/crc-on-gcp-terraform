variable "strategy" {
  type    = string
  description = "crc, snc or mnc"
  default = "crc"

  validation {
    condition     = contains(["crc", "snc", "mnc"], var.strategy)
    error_message = "Allowed values for input_parameter are \"crc\", \"snc\", or \"mnc\"."
  }
}

variable "gcp_vm_preemptible" {
  default = "true"
}

variable "gcp_vm_type" {
  default = "n1-standard-8"
  description = "crc or snc -> n1-standard-8; mnc ->  n1-standard-16 (recommended) or n2-highmem-8 "
}

variable "gcp_vm_disk_type" {
  default = "pd-standard"
  description = "pd-standard or pd-ssd"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "image" {
  default = "centos-8-v20210512"
  #default = "projects/okd4-280016/global/images/packer-1597358211"
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

#variable "subnetwork-region" {
#  default = "us-central1"
#}
#
#variable "network" {
#  default = "crc-network"
#}

variable "disk-name" {
  default = "crcdisk"
}

variable "gcp_vm_disk_size" {
  # The minimum size is 128GB due to the image (projects/okd4-280016/global/images/packer-1597358211).
  # You need to generate a new image (https://blog.kevinlin.info/post/google-compute-engine-reducing-the-size-of-a-persistent-disk) if you want to reduce the size.
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