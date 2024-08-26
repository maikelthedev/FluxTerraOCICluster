# Outputs for compute instance
output "instance_details" {
  value = {
    ocid = oci_core_instance.instance_config_arm.id
    public_ip = oci_core_instance.instance_config_arm.public_ip
    region = oci_core_instance.instance_config_arm.region
    time_created = oci_core_instance.instance_config_arm.time_created
  } 
}
