#!/bin/bash
# setup.sh - NVIDIA Brev上でIsaac Sim + cuRobo環境を構築する初期セットアップスクリプト
set -e

echo "=============================================="
echo "Isaac Sim + cuRobo Setup for NVIDIA Brev"
echo "=============================================="

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. システム確認
print_status "システム確認中..."

# GPU確認
if ! command -v nvidia-smi &> /dev/null; then
    print_error "nvidia-smi が見つかりません。NVIDIA GPUドライバがインストールされているか確認してください。"
    exit 1
fi

GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)
print_status "検出されたGPU: $GPU_INFO"

# Docker確認
if ! command -v docker &> /dev/null; then
    print_error "Dockerがインストールされていません。"
    exit 1
fi
print_status "Docker: $(docker --version)"

# NVIDIA Container Toolkit確認
if ! docker info 2>/dev/null | grep -q "nvidia"; then
    print_warning "NVIDIA Container Toolkitが設定されていない可能性があります。"
    print_status "インストールを試みます..."
    
    # NVIDIA Container Toolkitのインストール
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    sudo systemctl restart docker
fi

# 2. キャッシュディレクトリの作成
print_status "キャッシュディレクトリを作成中..."

ISAAC_SIM_CACHE_DIR="$HOME/docker/isaac-sim"

mkdir -p "$ISAAC_SIM_CACHE_DIR/cache/main/ov"
mkdir -p "$ISAAC_SIM_CACHE_DIR/cache/main/warp"
mkdir -p "$ISAAC_SIM_CACHE_DIR/cache/computecache"
mkdir -p "$ISAAC_SIM_CACHE_DIR/config"
mkdir -p "$ISAAC_SIM_CACHE_DIR/data/documents"
mkdir -p "$ISAAC_SIM_CACHE_DIR/data/Kit"
mkdir -p "$ISAAC_SIM_CACHE_DIR/logs"
mkdir -p "$ISAAC_SIM_CACHE_DIR/pkg"

# cuRobo用ディレクトリ
mkdir -p "$ISAAC_SIM_CACHE_DIR/curobo"

# 権限設定
sudo chown -R 1234:1234 "$ISAAC_SIM_CACHE_DIR"

print_status "キャッシュディレクトリ: $ISAAC_SIM_CACHE_DIR"

# 3. Isaac Simコンテナのプル
print_status "Isaac Simコンテナをプル中（数分かかる場合があります）..."
docker pull nvcr.io/nvidia/isaac-sim:5.1.0

# 4. パブリックIPの取得
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "取得失敗")
print_status "パブリックIP: $PUBLIC_IP"

# 5. 環境変数ファイルの作成
print_status "環境変数ファイルを作成中..."

cat > .env << EOF
# Isaac Sim Environment Variables
ISAAC_SIM_VERSION=5.1.0
ISAAC_SIM_CACHE_DIR=$ISAAC_SIM_CACHE_DIR
PUBLIC_IP=$PUBLIC_IP
WEBRTC_SIGNAL_PORT=49100
WEBRTC_STREAM_PORT=47998

# cuRobo Settings
CUROBO_VERSION=main
EOF

print_status ".env ファイルを作成しました"

# 6. セットアップ完了メッセージ
echo ""
echo "=============================================="
echo -e "${GREEN}セットアップ完了！${NC}"
echo "=============================================="
echo ""
echo "次のステップ:"
echo ""
echo "1. Isaac Simを起動:"
echo "   docker-compose up -d"
echo "   docker-compose exec isaac-sim bash"
echo ""
echo "2. コンテナ内でIsaac Simを起動:"
echo "   ./scripts/start-isaac-sim.sh"
echo ""
echo "3. WebRTC Streaming Clientで接続:"
echo "   - IP: $PUBLIC_IP"
echo "   - Port: 49100"
echo ""
echo "4. cuRoboをインストール（初回のみ）:"
echo "   ./scripts/install-curobo.sh"
echo ""
echo "=============================================="
