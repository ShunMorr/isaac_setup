#!/bin/bash
# start-streaming.sh - Isaac SimをWebRTCストリーミングモードで起動
# このスクリプトはコンテナ内で実行します

set -e

echo "=============================================="
echo "Isaac Sim ストリーミング起動"
echo "=============================================="

# パブリックIPを取得
PUBLIC_IP=$(curl -s ifconfig.me)

echo ""
echo "設定:"
echo "  Public IP: $PUBLIC_IP"
echo "  Signal Port: 49100 (TCP)"
echo "  Stream Port: 47998 (UDP)"
echo ""
echo "接続方法:"
echo "  1. Isaac Sim WebRTC Streaming Clientを起動"
echo "  2. Server欄に $PUBLIC_IP を入力"
echo "  3. Connectをクリック"
echo ""
echo "起動中... (初回は数分かかります)"
echo "「Isaac Sim Full Streaming App is loaded.」が表示されたら接続可能です"
echo ""

cd /isaac-sim
./runheadless.sh \
    --/app/livestream/publicEndpointAddress=$PUBLIC_IP \
    --/app/livestream/port=49100
