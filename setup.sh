#!/bin/bash
# setup.sh - NVIDIA Brev上でIsaac Sim + cuRobo環境を構築する初期セットアップスクリプト
set -e

echo "=============================================="
echo "Isaac Sim + cuRobo セットアップ"
echo "=============================================="

# 色付き出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 1. GPU確認
print_status "GPU確認中..."
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)
    print_status "検出されたGPU: $GPU_INFO"
else
    print_warning "nvidia-smiが見つかりません"
fi

# 2. cuRoboをクローン
print_status "cuRoboをクローン中..."
if [ ! -d ~/curobo ]; then
    git clone https://github.com/NVlabs/curobo.git ~/curobo
    print_status "cuRoboをクローンしました"
else
    print_status "cuRoboは既に存在します"
fi

# 3. キャッシュディレクトリ作成
print_status "キャッシュディレクトリを作成中..."
mkdir -p ~/docker/isaac-sim/cache/main
mkdir -p ~/docker/isaac-sim/cache/computecache
mkdir -p ~/docker/isaac-sim/logs
mkdir -p ~/docker/isaac-sim/config
mkdir -p ~/docker/isaac-sim/data
mkdir -p ~/docker/isaac-sim/pkg
sudo chown -R 1234:1234 ~/docker/isaac-sim

# 4. scriptsディレクトリをコピー
print_status "スクリプトを準備中..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/isaac-scripts
cp "$SCRIPT_DIR/scripts/"* ~/isaac-scripts/ 2>/dev/null || true
chmod +x ~/isaac-scripts/* 2>/dev/null || true

# 5. Isaac Simコンテナをプル
print_status "Isaac Simコンテナをプル中（数分かかります）..."
docker pull nvcr.io/nvidia/isaac-sim:5.1.0

# 6. パブリックIP取得
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "取得失敗")

echo ""
echo "=============================================="
echo -e "${GREEN}セットアップ完了！${NC}"
echo "=============================================="
echo ""
echo "パブリックIP: $PUBLIC_IP"
echo ""
echo "次のステップ:"
echo ""
echo "1. Brevダッシュボードでポートを開放:"
echo "   - 49100 (TCP)"
echo "   - 47998 (UDP) ← 重要: UDPで開放"
echo ""
echo "2. コンテナを起動:"
echo "   ./start-container.sh"
echo ""
echo "3. コンテナ内でIsaac Simを起動:"
echo "   bash /scripts/start-streaming.sh"
echo ""
echo "4. WebRTC Clientで接続:"
echo "   Server: $PUBLIC_IP"
echo ""
echo "=============================================="

# streamの自動開始systemdサービスの作成
echo "systemdサービスをセットアップ中..."

# サービスファイルを作成
sudo tee /etc/systemd/system/isaac-sim-streaming.service > /dev/null << 'SERVICEEOF'
[Unit]
Description=Isaac Sim Streaming Service
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/home/ubuntu/isaac-scripts/start-streaming-daemon.sh
ExecStop=/usr/bin/docker stop isaac-sim
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEEOF

sudo systemctl daemon-reload
sudo systemctl enable isaac-sim-streaming.service

echo "セットアップ完了！"
echo "次回のVM起動時から自動的にストリーミングが開始されます"
echo "今すぐ開始: sudo systemctl start isaac-sim-streaming.service"