resource "oci_identity_compartment" "tf-compartment" {
  compartment_id = var.oci.tenancy_ocid
  description    = var.compartment_config.compartment_description
  name           = var.compartment_config.compartment_name
}