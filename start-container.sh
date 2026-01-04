#!/bin/bash
# start-container.sh - Isaac Simコンテナを起動
set -e

echo "=============================================="
echo "Isaac Sim コンテナ起動"
echo "=============================================="

# 既存のコンテナがあれば停止・削除
if docker ps -a --format '{{.Names}}' | grep -q '^isaac-sim$'; then
    echo "既存のisaac-simコンテナを停止中..."
    docker stop isaac-sim 2>/dev/null || true
    docker rm isaac-sim 2>/dev/null || true
fi

echo "コンテナを起動中..."

docker run --name isaac-sim \
    --entrypoint bash \
    -it \
    --gpus all \
    -e "ACCEPT_EULA=Y" \
    -e "PRIVACY_CONSENT=Y" \
    --rm \
    --network=host \
    -v ~/docker/isaac-sim/cache/main:/isaac-sim/.cache:rw \
    -v ~/docker/isaac-sim/cache/computecache:/isaac-sim/.nv/ComputeCache:rw \
    -v ~/docker/isaac-sim/logs:/isaac-sim/.nvidia-omniverse/logs:rw \
    -v ~/docker/isaac-sim/config:/isaac-sim/.nvidia-omniverse/config:rw \
    -v ~/docker/isaac-sim/data:/isaac-sim/.local/share/ov/data:rw \
    -v ~/docker/isaac-sim/pkg:/isaac-sim/.local/share/ov/pkg:rw \
    -v ~/curobo:/curobo:rw \
    -v ~/isaac-scripts:/scripts:ro \
    -u 1234:1234 \
    nvcr.io/nvidia/isaac-sim:5.1.0
