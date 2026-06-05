#!/bin/bash
# 1. Update the system and install NFS/EFS utilities
sudo apt-get update -y
sudo apt-get install -y binutils checkinstall git

# Clone and install the official AWS EFS helper for Ubuntu
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get install -y ./build/amazon-efs-utils*deb

# 2. Create the local mount point
sudo mkdir -p /mnt/efs

# 3. Mount EFS using TLS (Mandatory security per your IAM policy)
# The efs_id variable will be injected dynamically by Terraform
sudo mount -t efs -o tls ${efs_id}:/ /mnt/efs

# 4. Ensure the EFS volume mounts automatically on system reboot
echo "${efs_id}:/ /mnt/efs efs _netdev,tls,defaults 0 0" | sudo tee -a /etc/fstab

# 5. Install Docker automatically
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker