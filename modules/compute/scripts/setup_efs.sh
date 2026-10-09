#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

EFS_ID="${efs_id}"
MOUNT_POINT="/mnt/efs"

yum install -y amazon-efs-utils docker

# Mount EFS (retry: DNS/mount target can take a moment)
mkdir -p $MOUNT_POINT
for i in $(seq 1 10); do
  if mount -t efs -o tls $EFS_ID:/ $MOUNT_POINT; then break; fi
  echo "Mount attempt $i failed, retrying in 15s"
  sleep 15
done
# Abort if not mounted, so Postgres never writes to the local disk
mountpoint -q $MOUNT_POINT

grep -q "$EFS_ID" /etc/fstab || echo "$EFS_ID:/ $MOUNT_POINT efs _netdev,tls 0 0" >> /etc/fstab

# Docker must wait for the EFS mount on every boot
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/efs.conf <<'EOF'
[Unit]
RequiresMountsFor=/mnt/efs
EOF
systemctl daemon-reload
systemctl enable --now docker

# Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Folder layout on EFS
mkdir -p $MOUNT_POINT/app $MOUNT_POINT/postgres-data $MOUNT_POINT/backups

# Recovery: if the compose file already exists on EFS, start it automatically
if [ -f $MOUNT_POINT/app/docker-compose.yml ]; then
  cd $MOUNT_POINT/app
  docker compose up -d
fi