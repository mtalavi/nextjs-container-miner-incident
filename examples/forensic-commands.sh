#!/usr/bin/env bash
set -euo pipefail

# Defensive example only.
# Replace this with the name of the stopped container you are investigating.
CONTAINER_NAME="replace-with-container-name"
OUT_DIR="incident-evidence-$(date +%F-%H%M%S)"
mkdir -p "$OUT_DIR"

echo "Saving container metadata..."
docker inspect "$CONTAINER_NAME" > "$OUT_DIR/container-inspect.json" 2>/dev/null || true
docker diff "$CONTAINER_NAME" > "$OUT_DIR/container-diff.txt" 2>/dev/null || true
docker logs --timestamps "$CONTAINER_NAME" > "$OUT_DIR/container-logs.txt" 2>&1 || true

echo "Saving process and resource snapshots..."
ps -eo pid,ppid,user,stat,%cpu,%mem,comm,args --sort=-%cpu | head -50 > "$OUT_DIR/top-processes.txt" || true
docker stats --no-stream > "$OUT_DIR/docker-stats.txt" 2>/dev/null || true

echo "Evidence saved to: $OUT_DIR"

echo "Review the output manually before deleting or rebuilding anything."
