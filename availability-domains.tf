data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci.tenancy_ocid
}