#!/usr/bin/env bash
set -euo pipefail

# Control Plane
multipass launch 24.04 --name cp --cpus 2 --memory 4G --disk 20G

# Worker nodes
multipass launch 24.04 --name w1 --cpus 2 --memory 4G --disk 20G
multipass launch 24.04 --name w2 --cpus 2 --memory 4G --disk 20G

multipass exec cp -- bash -c 'curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-backend=none --disable-network-policy --disable=traefik --cluster-cidr=10.42.0.0/16" sh -'

CP_IP=$(multipass info cp --format json | jq -r '.info.cp.ipv4[0]')
TOKEN=$(multipass exec cp -- sudo cat /var/lib/rancher/k3s/server/node-token)


for vm in w1 w2; do
  multipass exec "$vm" -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=https://$CP_IP:6443 K3S_TOKEN=$TOKEN sh -"
done


mkdir -p ~/.kube
multipass exec cp -- sudo cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/$CP_IP/" > ~/.kube/config

kubectl get nodes
