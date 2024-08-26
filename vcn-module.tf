module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.5.4"
  # Required
  compartment_id = oci_identity_compartment.tf-compartment.id


  # Optional Inputs
  vcn_name      = var.network_config.vcn_name
  vcn_dns_label = "vcnmodule"
  vcn_cidrs     = var.network_config.vcn_cidrs

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
}