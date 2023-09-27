# TODO: Divide this in multiple files you lazy F. 
# TODO: Make every name and every server a variable

resource "hcloud_load_balancer" "load_balancer" {
  name               = "funky-load-balancer"
  load_balancer_type = "lb11"
  location           = "nbg1"
  labels = {
    type = "controlplane"
  }
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
    load_balancer_id = hcloud_load_balancer.load_balancer.id
    protocol         = "tcp"
    listen_port = 6443
    destination_port = 6443
}

resource "hcloud_load_balancer_target" "load_balancer_target" {
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  label_selector = "type=controlplane"
}

# Give the load balancer this private IP
resource "hcloud_load_balancer_network" "srvnetwork" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id       = hcloud_network.mynetwork.id
  ip               = "10.0.1.5"
}
