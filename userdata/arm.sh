#!/bin/sh

apt-get update
apt-get install ca-certificates curl -y

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
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin mosh fish -y

usermod -aG docker ubuntu

# Install k3s with Docker
cat <<EOF > configserver.yaml
write-kubeconfig-mode: "644"
tls-san:
  - "machine1.maikeladas.es"   
EOF

curl -sfL https://get.k3s.io | sh -s - server --docker --config='/root/configserver.yaml'

# Required because OCI security policies affect the VNC not the Ubuntu server. 
iptables -P INPUT ACCEPT  
iptables -I INPUT -p tcp -m tcp --dport 6443 -j ACCEPT
iptables --flush 

# TODO: make this permanent
cp /etc/rancher/k3s/k3s.yaml .kube/config


# This below should go once Kubernetes is up and running
echo "Hello World from `hostname -f`" > /var/www/html/index.html

service nginx enable
service nginx start


