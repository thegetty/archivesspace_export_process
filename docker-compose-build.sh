#!/bin/bash
set -euo pipefail

echo "Loading the Nexus credentials from the .env.build"
echo "REQUIRES: NEXUS_USER and NEXUS_PASSWORD!"

set -a
. .env.build
set +a

docker compose build --build-arg NEXUS_USER=$NEXUS_USER --build-arg NEXUS_PASSWORD=$NEXUS_PASSWORD 