# This exists just to simplify my part as I use Digital Ocean as DNS

resource "digitalocean_record" "subdomains" {
  for_each = { for name in var.domain.subdomains : name => name }

  domain = var.domain.name
  type   = "A"
  name   = each.value
  value  = oci_core_instance.instance_config_arm.public_ip
  depends_on = [
    oci_core_instance.instance_config_arm
  ]
}