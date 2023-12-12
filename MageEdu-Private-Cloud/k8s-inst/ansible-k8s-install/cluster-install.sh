#!/bin/bash
#
# install ansible
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt update
sudo apt install ansible

# generate ansible iventory hosts
cat <<EOF >> /etc/ansible/hosts
[master]
${MASTER_IP} node_ip=${MASTER_IP}

[nodes]
${NODE_01_IP} node_ip=${NODE_01_IP}
${NODE_02_IP} node_ip=${NODE_02_IP}
#${NODE_03_IP} node_ip=${NODE_03_IP}
EOF

# install containerd.io and kubeadm/kubelet/kubectl
ansible-playbook install-kubeadm.yaml

# create kubernetes cluster control plane and add work nodes
ansible-playboot install-k8s-flannel.yaml
