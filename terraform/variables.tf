# ----- provider -----

variable "oci_region" {
  type      = string
  sensitive = true
}

variable "oci_tenancy_ocid" {
  type      = string
  sensitive = true
}

variable "oci_user_ocid" {
  type      = string
  sensitive = true
}

variable "oci_fingerprint" {
  type      = string
  sensitive = true
}

variable "oci_private_key_base64" {
  type      = string
  sensitive = true
}


# ----- resources -----

# Base/Shared

variable "oci_vcn_id" {
  type    = string
  default = null
}

variable "oci_internet_gateway_id" {
  type    = string
  default = null
}

variable "oci_route_table_id" {
  type    = string
  default = null
}

variable "oci_security_list_id" {
  type    = string
  default = null
}

variable "oci_subnet_id" {
  type    = string
  default = null
}

variable "oci_image_id" {
  type    = string
  default = null
}


# VCN

variable "vcn_cidr_blocks" {
  type    = list(any)
  default = ["172.16.0.0/20"]
}

variable "vcn_display_name" {
  type    = string
  default = "nefertiti-vcn"
}

# Network

variable "internet_gateway_display_name" {
  type    = string
  default = "nefertiti-igw"
}

variable "route_table_display_name" {
  type    = string
  default = "nefertiti-rt"
}

variable "security_list_display_name" {
  type    = string
  default = "nefertiti-sl"
}

variable "subnet_cidr_block" {
  type    = string
  default = "172.16.0.0/24"
}

variable "subnet_display_name" {
  type    = string
  default = "nefertiti-subnet"
}

variable "your_home_public_ip" {
  type      = string
  sensitive = true
}

variable "reserved_public_ip" {
  type    = string
  default = "nefertiti-public-ip"
}

variable "use_reserved_public_ip" {
  type    = string
  default = false
}

# Instance

variable "instance_shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "instance_display_name" {
  type    = string
  default = "nefertiti"
}

variable "instance_shape_config_baseline_ocpu_utilization" {
  type    = string
  default = "BASELINE_1_1"
}

variable "instance_shape_config_memory_in_gbs" {
  type    = number
  default = 6
}

variable "instance_shape_config_ocpus" {
  type    = number
  default = 1
}

variable "instance_source_details_boot_volume_size_in_gbs" {
  type    = number
  default = 50
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

# user data

variable "docker_compose_version" {
  type    = string
  default = ""
}

variable "docker_network_range" {
  type      = string
  sensitive = false
  default   = "10.7.0.0/16"
}

# Nefertiti

variable "nefertiti_version" {
  type    = string
  default = "latest"
}

variable "test" {
  type    = string
  default = "true"
}

variable "api_key" {
  type      = string
  sensitive = true
}

variable "api_secret" {
  type      = string
  sensitive = true
}

variable "api_passphrase" {
  type      = string
  sensitive = true
}

variable "debug" {
  type    = string
  default = "true"
}

variable "earn" {
  type    = string
  default = ""
}

variable "exchange" {
  type = string
}

variable "hold" {
  type    = string
  default = ""
}

variable "mult" {
  type    = string
  default = ""
}

variable "notify" {
  type    = string
  default = ""
}

variable "quote" {
  type    = string
  default = "USDT"
}

variable "sandbox" {
  type    = string
  default = ""
}

variable "stoploss" {
  type    = string
  default = ""
}

variable "agg" {
  type    = string
  default = ""
}

variable "dca" {
  type    = string
  default = "true"
}

variable "devn" {
  type    = string
  default = ""
}

variable "dip" {
  type    = string
  default = ""
}

variable "dist" {
  type    = string
  default = ""
}

variable "ignore" {
  type    = string
  default = "USDT_USD"
}

variable "market" {
  type    = string
  default = "all"
}

variable "min" {
  type    = string
  default = ""
}

variable "pip" {
  type    = string
  default = ""
}

variable "price" {
  type = string
}

variable "repeat" {
  type    = string
  default = "1"
}

variable "signals" {
  type    = string
  default = ""
}

variable "size" {
  type    = string
  default = ""
}

variable "strict" {
  type    = string
  default = ""
}

variable "top" {
  type    = string
  default = "1"
}

variable "valid" {
  type    = string
  default = ""
}

variable "volume" {
  type    = string
  default = "10"
}
