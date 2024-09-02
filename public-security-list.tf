resource "oci_core_security_list" "public-security-list" {
  # Required
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id

  # Optional
  display_name = "security-list-for-public-subnet"

  # Let the instance access the world
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  

  dynamic "ingress_security_rules" {
    for_each = var.ip_for_ssh
    content {
      stateless   = false
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      protocol    = "6"
      tcp_options {
        min = 22
        max = 22
      }
    }
  }

    dynamic "ingress_security_rules" {
    for_each = var.ip_for_ssh
    content {
      stateless   = false
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      protocol    = "6"
      tcp_options {
        min = 6443
        max = 6443
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.open_ports
    content {
      stateless   = false
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = "17" # Number for UDP

      tcp_options {
        min = ingress_security_rules.value
        max = ingress_security_rules.value
      }
    }
  }

}