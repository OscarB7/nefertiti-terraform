output "local_oci_vcn_id" {
  value = local.oci_vcn_id
}

output "local_oci_internet_gateway_id" {
  value = local.oci_internet_gateway_id
}

output "local_oci_route_table_id" {
  value = local.oci_route_table_id
}

output "local_oci_security_list_id" {
  value = local.oci_security_list_id
}

output "local_oci_subnet_id" {
  value = local.oci_subnet_id
}

output "local_oci_image_id" {
  value = local.oci_image_id
}

output "availability_domains" {
  value = data.oci_identity_availability_domains.availability_domains.availability_domains[0]["name"]
}

output "image_name" {
  value = data.oci_core_images.ubuntu_image.images.0.display_name
}

output "image_id" {
  value = data.oci_core_images.ubuntu_image.images.0.id
}

output "instance_public_ip" {
  value = oci_core_instance.new_instance.public_ip
}
