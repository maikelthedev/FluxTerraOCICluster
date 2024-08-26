resource "oci_core_instance" "instance_config_arm" {
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = oci_identity_compartment.tf-compartment.id
    shape = var.instance_config_arm.shape
    
    shape_config {
        memory_in_gbs = var.instance_config_arm.shape_memory
        ocpus = var.instance_config_arm.shape_ocpus
    }

    source_details { 
        source_id = var.instance_config_arm.image_id
        source_type = "image"
    }

    display_name = var.instance_config_arm.display_name
    
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.vcn-public-subnet.id
    }

    metadata = {
        ssh_authorized_keys = file(var.instance_config_arm.ssh_key_path)
        user_data = "${base64encode(file(var.instance_config_arm.userdata_file_path))}"   
    } 
    preserve_boot_volume = false
}
