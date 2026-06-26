#!/usr/bin/env bash
set -euo pipefail

# Defensive example only.
# Set PROJECT_LABEL to your Docker Compose project label value.
PROJECT_LABEL="replace-with-compose-project-label"

echo "Running containers for project: $PROJECT_LABEL"
docker ps --filter "label=com.docker.compose.project=$PROJECT_LABEL" \
  --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"

echo
echo "Checking for common miner-related strings in process lists..."
for C in $(docker ps --filter "label=com.docker.compose.project=$PROJECT_LABEL" --format "{{.Names}}"); do
  echo "----- $C -----"
  docker exec "$C" sh -lc 'ps aux 2>/dev/null | grep -Ei "xmrig|randomx|softirq|qkpucq|rondo" | grep -v grep || true' 2>/dev/null || true
done

echo
echo "Resource usage snapshot:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
