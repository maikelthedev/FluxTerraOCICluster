variable "github" {
  type = object({
    repo = string
    bot_name = string
    org  = string
    token = string
  })
}

variable "oci" {
  type = object({
    user_ocid = string
    fingerprint = string
    tenancy_ocid = string
    region = string
    private_key_path = string
  })
}


variable "flux_cluster_path" { }
variable "do_token" { }

variable "domain" {
  description = "Domain to use as example and list of strings"
  type = object({
    name = string
    subdomains = list(string)
  })
}


variable "instances_config" {
  type = object({
    cplane_nodes = number
    worker_nodes = number
    cplanes_start_ip = number
    workers_start_ip = number
    prefix_ip = string
    cplane_type = string
    worker_type = string
  })
  default =  {
    cplane_nodes = 3
    worker_nodes = 2
    cplanes_start_ip = 10
    workers_start_ip = 20
    prefix_ip = "10.0.1."
    worker_type =  "cax31"
    cplane_type = "cax11"
  }
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = "funky-cluster"
}

variable "compartment_config" {
  type = object({
    compartment_description = string
    compartment_name        = string
  })
  description = "Location where  all this deployment is going to be compartimentalised"
}

variable "network_config" {
    type = object({
      private_subnet_cidr_block = string
      private_subnet_name = string
      public_subnet_cidr_block = string
      public_subnet_name = string
      vcn_cidrs = list(string)
      vcn_name = string
    })
    description = "Details about the private & public subnets and the VCN"
}

variable "open_ports" {
  type = list(number)
  default = [22]
}

variable "ip_for_ssh" {
  description = "List of IP addresses allowed to access SSH"
  type        = list(string)
}


variable "instance_config_arm" {
  type = object({
    shape = string
    image_id = string
    display_name = string
    ssh_key_path = string
    shape_memory = number
    shape_ocpus = number
    userdata_file_path = string
  })
  description = "Details about the instance you're going to run the dev environment from"
}