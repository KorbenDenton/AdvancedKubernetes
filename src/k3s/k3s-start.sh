#!/bin/bash

sudo apt-get update && sudo apt-get upgrade

if [[ $(hostname) == "k3s-master" ]]; then
    curl -fL https://raw.githubusercontent.com/k3s-io/k3s/master/install.sh | sh -s - server --disable=traefik --flannel-iface=enp0s8 --node-ip=192.168.33.10
    sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token
    mkdir -p ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    echo 'export KUBECONFIG=~/.kube/config' >> /home/vagrant/.bashrc
    source /home/vagrant/.bashrc
    sudo systemctl enable k3s 
    sudo mkdir -p /data/postgres
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.1/cert-manager.yaml
fi

NODE_TOKEN=$(cat /vagrant/node-token)

if [[ $(hostname) == "k3s-worker1" ]]; then
    while [ ! -f /vagrant/node-token ]; do sleep 1; done
    curl -fL https://raw.githubusercontent.com/k3s-io/k3s/master/install.sh | sh -s - agent --server=https://192.168.33.10:6443 --token=$NODE_TOKEN --flannel-iface=enp0s8 --node-ip=192.168.33.11
    sudo systemctl enable k3s-agent 
    sudo mkdir -p /data/postgres
fi
if [[ $(hostname) == "k3s-worker2" ]]; then
    while [ ! -f /vagrant/node-token ]; do sleep 1; done
    curl -fL https://raw.githubusercontent.com/k3s-io/k3s/master/install.sh | sh -s - agent --server=https://192.168.33.10:6443 --token=$NODE_TOKEN --flannel-iface=enp0s8 --node-ip=192.168.33.12
    sudo systemctl enable k3s-agent
    sudo mkdir -p /data/postgres
fi

sudo rm /vagrant/node-token