data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.oci_tenancy_ocid
}


resource "oci_core_vcn" "new_vcn" {
  count = var.oci_vcn_id == null ? 1 : 0

  compartment_id = var.oci_tenancy_ocid
  cidr_blocks    = var.vcn_cidr_blocks
  display_name   = var.vcn_display_name
}


locals {
  oci_vcn_id = var.oci_vcn_id == null ? oci_core_vcn.new_vcn[0].id : var.oci_vcn_id
}


resource "oci_core_internet_gateway" "new_internet_gateway" {
  count = var.oci_internet_gateway_id == null ? 1 : 0

  compartment_id = var.oci_tenancy_ocid
  vcn_id         = local.oci_vcn_id
  enabled        = true
  display_name   = var.internet_gateway_display_name
}


locals {
  oci_internet_gateway_id = var.oci_internet_gateway_id == null ? oci_core_internet_gateway.new_internet_gateway[0].id : var.oci_internet_gateway_id
}


resource "oci_core_route_table" "new_route_table" {
  count = var.oci_route_table_id == null ? 1 : 0

  compartment_id = var.oci_tenancy_ocid
  vcn_id         = local.oci_vcn_id
  display_name   = var.route_table_display_name
  route_rules {
    network_entity_id = local.oci_internet_gateway_id
    description       = "Internet access"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}


locals {
  oci_route_table_id = var.oci_route_table_id == null ? oci_core_route_table.new_route_table[0].id : var.oci_route_table_id
}


resource "oci_core_security_list" "new_security_list" {
  count = var.oci_security_list_id == null ? 1 : 0

  compartment_id = var.oci_tenancy_ocid
  vcn_id         = local.oci_vcn_id
  display_name   = var.security_list_display_name
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "allow all outbound traffic from the instance"
    stateless   = false
  }
  ingress_security_rules {
    protocol    = 6 # 6=TCP
    source      = var.your_home_public_ip
    description = "allow 22/TCP (SSH) inbound traffic from home"
    stateless   = false
    tcp_options {
      max = 22
      min = 22
    }
  }
}


locals {
  oci_security_list_id = var.oci_security_list_id == null ? oci_core_security_list.new_security_list[0].id : var.oci_security_list_id
}


resource "oci_core_subnet" "new_public_subnet" {
  count = var.oci_subnet_id == null ? 1 : 0

  cidr_block          = var.subnet_cidr_block
  compartment_id      = var.oci_tenancy_ocid
  vcn_id              = local.oci_vcn_id
  availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[0]["name"]
  display_name        = var.subnet_display_name
  route_table_id      = local.oci_route_table_id
  security_list_ids   = [local.oci_security_list_id]
}


locals {
  oci_subnet_id = var.oci_subnet_id == null ? oci_core_subnet.new_public_subnet[0].id : var.oci_subnet_id
}


data "oci_core_images" "ubuntu_image" {
  compartment_id           = var.oci_tenancy_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "20.04"
  shape                    = var.instance_shape
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}


locals {
  oci_image_id = var.oci_image_id == null ? data.oci_core_images.ubuntu_image.images.0.id : var.oci_image_id
}


resource "oci_core_instance" "new_instance" {
  availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[0]["name"]
  compartment_id      = var.oci_tenancy_ocid
  shape               = var.instance_shape
  create_vnic_details {
    assign_public_ip = !var.use_reserved_public_ip
    subnet_id        = local.oci_subnet_id
  }
  display_name = var.instance_display_name
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile(
      "user_data/bootstrap.tftpl",
      {
        agg                    = var.agg,
        api_key                = var.api_key,
        api_passphrase         = var.api_passphrase,
        api_secret             = var.api_secret,
        dca                    = var.dca,
        debug                  = var.debug,
        devn                   = var.devn,
        dip                    = var.dip,
        dist                   = var.dist,
        docker_compose_version = var.docker_compose_version,
        docker_network_range   = var.docker_network_range,
        earn                   = var.earn,
        exchange               = var.exchange,
        hold                   = var.hold,
        ignore                 = var.ignore,
        market                 = var.market,
        min                    = var.min,
        mult                   = var.mult,
        nefertiti_version      = var.nefertiti_version,
        notify                 = var.notify,
        pip                    = var.pip,
        price                  = var.price,
        quote                  = var.quote,
        repeat                 = var.repeat,
        sandbox                = var.sandbox,
        signals                = var.signals,
        size                   = var.size,
        stoploss               = var.stoploss,
        strict                 = var.strict,
        test                   = var.test,
        top                    = var.top,
        valid                  = var.valid,
        volume                 = var.volume,
      }
    ))
  }
  shape_config {
    baseline_ocpu_utilization = var.instance_shape_config_baseline_ocpu_utilization
    memory_in_gbs             = var.instance_shape_config_memory_in_gbs
    ocpus                     = var.instance_shape_config_ocpus
  }
  source_details {
    source_id               = local.oci_image_id
    source_type             = "image"
    boot_volume_size_in_gbs = var.instance_source_details_boot_volume_size_in_gbs
  }
  preserve_boot_volume = false
}


data "oci_core_private_ips" "new_instance_private_ips" {
  ip_address = oci_core_instance.new_instance.private_ip
  subnet_id  = local.oci_subnet_id
}


resource "oci_core_public_ip" "new_public_ip" {
  count = var.use_reserved_public_ip ? 1 : 0

  compartment_id = var.oci_tenancy_ocid
  display_name   = var.reserved_public_ip
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.new_instance_private_ips.private_ips[0]["id"]
  lifecycle {
    prevent_destroy = true
  }
}


locals {
  oci_reserved_public_ip = var.use_reserved_public_ip ? oci_core_public_ip.new_public_ip[0].ip_address : ""
}
