terraform {
  required_providers {
    oci = { # Without this there's a conflict with hashicorp/oci
      source = "oracle/oci"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.1.1"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 1.22.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

