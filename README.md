## What is it?
It is a Kubernetes cluster for testing purposes or really small services running on a free-tier OCI instance. with Flux and written in Terraform. 

It's also going to become the blueprint for [maikel.dev](https://maikel.dev/) which I intent to rewrite using Phoenix as I'm very disappointed with NextJS. 

## Install Terraform

In NixOS this was editing configuration.nix to add "terraform" then just apply the changes. 

## Install OCI CLI and test it

Once this is up and running then it is easy to ensure the variables are right in terraform since for this to work I have to assign them all. Let alone this is an exercise in Nixos dev machine design too. 

Nixos has it in its package list [here](https://search.nixos.org/packages?channel=24.05&show=oci-cli&from=0&size=50&sort=relevance&type=packages&query=oci) so I can just add it, but more useful would be to be able to also configure it from configuration.nix so I'm going to find out if that's possible, that way I can replicate this across my 3 machines easily. 

Once installed

```bash
oci setup config
```

And that gives me all the variables. [This sectin on the OCI documentation](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#Other) has more information about how to set it up. I created two keys, one from the console and one from the CLI just to be sure and to try two ways. 

To test it works just run any command to get info, such as 👇

```bash
oci os ns get
```

So just amend providers.tf with the info provided or better terraform.tfvars so it's out of the repo. 

I ended up not finding the NixOS way because anyway I configured it all in tfvars. 
## Install the OCI providers and initialise them

For the OCI providers all that is needed is this on terraform

```hcl
# providers.tf

provider "oci" {
	user_ocid = var.oci.user_ocid
	fingerprint = var.oci.fingerprint
	tenancy_ocid = var.oci.tenancy_ocid
	region = var.oci.region
	private_key_path = var.oci.private_key_path
}

# versions.tf

terraform {
	required_providers {
		oci = { # Without this there's a conflict with hashicorp/oci
			source = "oracle/oci"
		}
	}
}

# terraform.tfvars - This one is not on the repo obviously. 
oci = {
	user_ocid = "ocid1.user.oc1..aaaa...."
	fingerprint = "26:37:e...."
	tenancy_ocid = "ocid1.tenancy.oc1..aa..."
	region = "eu-madrid-1"
	private_key_path = "~/.oci/oci_api_key.pem" # TODO: This is the one you should modify.
}
```

The information for the variables is what I received as the step after setting up the CLI. You don't need to look for that info manually anywhere. 

## Configure Digital Ocean CLI

The package is [doctl](https://search.nixos.org/packages?channel=24.05&show=doctl&from=0&size=50&sort=relevance&type=packages&query=doctl) in Nixos. I use Digital Ocean because the DNS capabilities it has are all free. 

The file where the config is saved is on ~/.config/doctl/config.yaml I wanted to start from scratch so I deleted it and all API keys. 

Then just

```bash
doctl auth init --context default  
```
And just paste the token. Use that same token in terraform.tfvars. To test it works

```bash
doctl balance get
```

## Launch a first test instance

This is a good milestone to check everything is correct. Stuff copied across from another project to be able to run the first instance (this is the number of stuff needed to launch an instance, since defining the instance is never enough):
* Availability domain
* Identity compartment
* Virtual Cloud network
* Public Security List
* Public Subnet
* Private Subnet
* Compute machine
## Cloud-init basic setup

I'm using Ubuntu so i'm just doing enough to have a page that directs to the instance proving it works. 

```bash
#!/bin/sh

apt-get update
apt-get install nginx -y
echo "Hello World from `hostname -f`" > /var/www/html/index.html

service nginx enable
service nginx start

iptables -P INPUT ACCEPT
iptables --flush
```

You might wonder why the part of iptables. This is an annoyance I've found with Oracle Cloud Infrastructure and it is that Security Policies don't apply at OS level. So even after I defined that port 80 is open, unless in Ubuntu I accept connections from all ports, it won't let me connect to port 80. Oracle only configures the firewall at VNC level and completely ignores Ubuntu. It does work at OS level if you choose Oracle Linux. 

## Configure DNS

This step is required so that I don't have to keep updating the IP whenever I destroy and rebuild the environment. This is why I use Digital Ocean. 

```hcl
# domains.tf
resource "digitalocean_record" "subdomains" {
	for_each = { for name in var.domain.subdomains : name => name }
	domain = var.domain.name
	type = "A"
	name = each.value
	value = oci_core_instance.instance_config_arm.public_ip
	depends_on = [
		oci_core_instance.instance_config_arm
	]
}

# variables.tf
variable "domain" {
	description = "Domain to use as example and list of strings"
	type = object({
		name = string
		subdomains = list(string)
	})
}

# terraform.tfvars
domain = {
	description = "Domain to use as example and list of strings"
	name = "maikeladas.es"
	subdomains = ["machine1", "machine2" ]
}
```

By mere virtue of having a DNS now I can configure `.ssh/config` to allow me to access the instance independently of destroying it and launching it again. So

```txt
Host machine1
	HostName machine1.maikeladas.es
	User ubuntu
```

Now I can ssh into it with a simple `ssh machine1`with nothing more. 

## Adding Kubernetes to the server

The first part is that I like to use Docker with Kubernetes, not just containerd so I want K3S, my favourite flavour of Kubernetes with it. The reason also to use it with Docker is that gets rid of incompatibility issues with Cert-Manager later on. 

This is a matter of modifying the cloud-init script to do both things.

```sh
#!/bin/sh
apt-get update
apt-get install nginx ca-certificates curl -y

# Add Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Give the user rights to it
usermod -aG docker ubuntu

# Install k3s but using Docker as containerisation method
curl -sfL https://get.k3s.io | sh -s - --docker
```

## Configuring local Kubectl


## TODO
* [x] Install Terraform
* [x] Install the OCI providers and initialise them
* [x] Install DOCTL providers and initialise them
* [x] Launch an instance with basic NGINX page
* [x] Configure basic DNS to avoid remembering IPs. 
* [x] Add Kubernetes to the server
* [ ] Install kubctl
* [ ] Install Flux
* [ ] Install Let's Encrypt
* [ ] Serve a basic page over SSL. 
* [ ] Serve a Phoenix project
* [ ] Serve Fedigrindr basic template
* [ ] Serve maikel.dev 
* [ ] Amend README.md