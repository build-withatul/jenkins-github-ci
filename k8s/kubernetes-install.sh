#!/bin/bash

set -e

echo "========================================="
echo " Kubernetes kubeadm Installation"
echo " Ubuntu"
echo "========================================="

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run this script with sudo."
    echo "Example: sudo ./kubernetes-install.sh"
    exit 1
fi

echo
echo "[1/8] Disabling swap..."
swapoff -a
sed -i '/[[:space:]]swap[[:space:]]/ s/^/#/' /etc/fstab

echo
echo "[2/8] Loading kernel modules..."

cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

echo
echo "[3/8] Configuring Kubernetes networking..."

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

echo
echo "[4/8] Installing required packages..."

apt-get update

apt-get install -y \
    ca-certificates \
    curl \
    gpg \
    apt-transport-https \
    containerd

echo
echo "[5/8] Configuring containerd..."

mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' \
    /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo
echo "Containerd status:"
systemctl --no-pager --full status containerd | head -20

echo
echo "[6/8] Adding Kubernetes repository..."

mkdir -p /etc/apt/keyrings

curl -fsSL \
    https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' \
    > /etc/apt/sources.list.d/kubernetes.list

apt-get update

echo
echo "[7/8] Installing kubeadm, kubelet and kubectl..."

apt-get install -y kubelet kubeadm kubectl

apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet

echo
echo "[8/8] Verifying installation..."

echo
echo "containerd:"
containerd --version

echo
echo "kubeadm:"
kubeadm version

echo
echo "kubectl:"
kubectl version --client

echo
echo "kubelet:"
kubelet --version

echo
echo "========================================="
echo " Kubernetes prerequisites installed!"
echo "========================================="

echo
echo "NEXT STEP:"
echo
echo "On CONTROL-PLANE:"
echo "  sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
echo
echo "Then configure kubectl:"
echo "  mkdir -p \$HOME/.kube"
echo "  sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config"
echo "  sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"
echo
echo "========================================="
