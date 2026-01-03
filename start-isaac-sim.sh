#!/bin/bash
# start-isaac-sim.sh - Isaac SimをWebRTCストリーミングモードで起動
set -e

echo "=============================================="
echo "Isaac Sim 起動スクリプト"
echo "=============================================="

# パブリックIPの取得
if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")
fi

# ポート設定
SIGNAL_PORT=${WEBRTC_SIGNAL_PORT:-49100}
STREAM_PORT=${WEBRTC_STREAM_PORT:-47998}

echo ""
echo "設定:"
echo "  Public IP: $PUBLIC_IP"
echo "  Signal Port: $SIGNAL_PORT"
echo "  Stream Port: $STREAM_PORT"
echo ""

# 起動モード選択
MODE=${1:-"headless"}

case $MODE in
    "headless")
        echo "ヘッドレスモード（WebRTCストリーミング）で起動..."
        echo ""
        echo "接続方法:"
        echo "  1. Isaac Sim WebRTC Streaming Clientを起動"
        echo "  2. IP: $PUBLIC_IP, Port: $SIGNAL_PORT を入力"
        echo "  3. Connectをクリック"
        echo ""
        
        ./runheadless.sh \
            --/exts/omni.kit.livestream.app/primaryStream/publicIp=$PUBLIC_IP \
            --/exts/omni.kit.livestream.app/primaryStream/signalPort=$SIGNAL_PORT \
            --/exts/omni.kit.livestream.app/primaryStream/streamPort=$STREAM_PORT
        ;;
    
    "native")
        echo "ネイティブストリームモードで起動..."
        ./runheadless.native.sh \
            --/app/livestream/publicEndpointAddress=$PUBLIC_IP \
            --/app/livestream/port=$SIGNAL_PORT
        ;;
    
    "no-stream")
        echo "ストリーミングなしで起動（ヘッドレス処理用）..."
        ./runheadless.sh --no-livestream
        ;;
    
    *)
        echo "使用方法: $0 [headless|native|no-stream]"
        echo ""
        echo "  headless   - WebRTCストリーミング（デフォルト）"
        echo "  native     - ネイティブストリーミング"
        echo "  no-stream  - ストリーミングなし（バッチ処理用）"
        exit 1
        ;;
esac
