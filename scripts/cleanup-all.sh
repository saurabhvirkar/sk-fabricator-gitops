#!/usr/bin/env bash
# ==============================================================================
# Full Cleanup Script: Stops & Removes All Previous Docker Containers & Kind Clusters
# ==============================================================================

set -euo pipefail

echo "=== [Cleanup] Stopping & Deleting All Previous Docker Containers & Kind Clusters ==="

# 1. Stop all Docker Containers
echo "[1/4] Stopping all running Docker containers..."
if command -v docker &> /dev/null; then
  docker stop $(docker ps -aq) 2>/dev/null || true
  docker rm $(docker ps -aq) 2>/dev/null || true
  echo "[✓] All Docker containers stopped and removed."
fi

# 2. Stop Docker Compose stacks if active
echo "[2/4] Down-scaling Docker Compose stacks..."
if [ -d "/home/saurabh/Project/sk/SkFabricatorAndErector-Backend" ]; then
  cd /home/saurabh/Project/sk/SkFabricatorAndErector-Backend
  docker compose down -v 2>/dev/null || true
fi

# 3. Clean up Docker volumes & networks
echo "[3/4] Pruning Docker system resources..."
if command -v docker &> /dev/null; then
  docker system prune -f 2>/dev/null || true
fi

# 4. Delete Kind Kubernetes cluster state
echo "[4/4] Deleting Kind Kubernetes cluster ('skops')..."
if command -v kind &> /dev/null; then
  kind delete cluster --name skops 2>/dev/null || true
  kind delete clusters --all 2>/dev/null || true
  echo "[✓] Kind cluster deleted."
fi

echo -e "\n[✓] CLEANUP COMPLETE! System is 100% clean and ready for a fresh Kind GitOps start."
