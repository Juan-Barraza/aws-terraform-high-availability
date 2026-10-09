#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

COMPOSE_VERSION="v2.29.7"

yum install -y docker
systemctl enable --now docker

mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version

echo "Docker setup completed successfully!"