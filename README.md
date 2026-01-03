# NVIDIA Brev で Isaac Sim + cuRobo を用いた UR5 経路最適化環境

NVIDIA Brev上でIsaac SimとcuRoboを使用してUR5ロボットの経路最適化を行うための軽量セットアップです。

## 概要

このリポジトリは、Isaac Launchableを使用せず、最小限のリソースでIsaac Sim + cuRobo環境を構築するためのスクリプト集です。

### 特徴

- **軽量**: Isaac Simコンテナのみ起動（VSCode/Viewerコンテナ不要）
- **低コスト**: L40S 1台で動作、必要最小限のリソース消費
- **柔軟**: cuRoboの設定をカスタマイズ可能

### 含まれるもの

```
brev-isaac-ur5-setup/
├── README.md                 # この手順書
├── setup.sh                  # 初期セットアップスクリプト
├── docker-compose.yml        # Isaac Simコンテナ定義
├── scripts/
│   ├── start-isaac-sim.sh    # Isaac Sim起動スクリプト
│   ├── install-curobo.sh     # cuRoboインストールスクリプト
│   └── run-ur5-motion.sh     # UR5モーション生成実行スクリプト
└── configs/
    └── ur5e_custom.yml       # UR5e用cuRobo設定テンプレート
```

---

## 前提条件

- NVIDIA Brevアカウント
- Isaac Sim WebRTC Streaming Clientアプリ（UIを使用する場合）
  - ダウンロード: https://docs.isaacsim.omniverse.nvidia.com/latest/installation/manual_livestream_clients.html

---

## セットアップ手順

### 1. Brevインスタンスの作成

1. [NVIDIA Brev](https://developer.nvidia.com/brev) にアクセス
2. **Get Started** → サインインまたはアカウント作成
3. **Create New Instance** をクリック
4. **1x NVIDIA L40S** GPUを選択
5. インスタンスに名前を付けて **Deploy**
6. VMの準備完了まで待機

### 2. ポートの開放

Brevインスタンスページで以下のポートを開放：

| ポート | 用途 |
|--------|------|
| 49100  | WebRTC シグナリング |
| 47998  | WebRTC ストリーミング |

> **セキュリティ**: 自分のIPアドレスのみに制限することを推奨

### 3. インスタンスへの接続

```bash
# BrevのSSHコマンドを使用（インスタンスページに表示）
ssh user@<instance-ip>
```

### 4. このリポジトリのクローンと初期セットアップ

```bash
git clone https://github.com/<your-username>/brev-isaac-ur5-setup.git
cd brev-isaac-ur5-setup
chmod +x setup.sh scripts/*.sh
./setup.sh
```

---

## 使用方法

### Isaac Simの起動

#### 方法A: docker-compose を使用（推奨）

```bash
# コンテナをバックグラウンドで起動
docker-compose up -d

# コンテナ内に入る
docker-compose exec isaac-sim bash

# Isaac Simをヘッドレスモードで起動（コンテナ内で実行）
./scripts/start-isaac-sim.sh
```

#### 方法B: 直接実行

```bash
./scripts/start-isaac-sim.sh
```

### WebRTC Streaming Clientでの接続

1. Isaac Sim WebRTC Streaming Clientアプリを起動
2. BrevインスタンスのパブリックIPを入力
3. ポート: 49100
4. **Connect** をクリック

### cuRoboのインストール（初回のみ）

```bash
# Isaac Simコンテナ内で実行
./scripts/install-curobo.sh
```

### UR5経路最適化の実行

```bash
# Isaac Simコンテナ内で実行
./scripts/run-ur5-motion.sh

# または直接実行
cd /curobo
python examples/isaac_sim/motion_gen_reacher.py --robot ur5e.yml --visualize_spheres
```

---

## カスタマイズ

### UR5e設定のカスタマイズ

`configs/ur5e_custom.yml` を編集して、以下をカスタマイズ可能：

- 関節の速度・加速度制限
- 衝突球の設定
- エンドエフェクタの定義

### 障害物の追加

cuRoboでは以下の形式で障害物を定義可能：

- Cuboid（直方体）
- Mesh（メッシュ）
- nvbloxマップ（深度カメラから生成）

---

## トラブルシューティング

### コンテナが起動しない

```bash
# GPUが認識されているか確認
nvidia-smi

# Dockerのランタイム確認
docker info | grep -i runtime
```

### WebRTC接続できない

1. ポート49100, 47998が開放されているか確認
2. ファイアウォール設定を確認
3. Isaac Simが完全に起動しているか確認（`app ready`メッセージ）

### cuRoboインストールエラー

```bash
# PyTorchバージョン確認
python -c "import torch; print(torch.__version__)"

# CUDAバージョン確認
nvcc --version
```

---

## コスト最適化のヒント

1. **使用後は必ずインスタンスを停止**
   - Brevダッシュボードから **Stop** をクリック
   - 停止中はストレージ料金のみ

2. **キャッシュの活用**
   - `~/docker/isaac-sim/cache` にシェーダーキャッシュが保存される
   - 2回目以降の起動が高速化

3. **必要な時だけ起動**
   - ヘッドレストレーニング中はWebRTC不要
   - 結果確認時のみストリーミング使用

---

## ライセンス

- Isaac Sim: [NVIDIA Omniverse License Agreement](https://docs.omniverse.nvidia.com/platform/latest/common/NVIDIA_Omniverse_License_Agreement.html)
- cuRobo: 非商用目的のみ（商用利用はNVIDIAへの問い合わせが必要）

---

## 参考リンク

- [Isaac Sim Documentation](https://docs.isaacsim.omniverse.nvidia.com/)
- [cuRobo Documentation](https://curobo.org/)
- [NVIDIA Brev](https://developer.nvidia.com/brev)
- [Isaac ROS cuMotion](https://nvidia-isaac-ros.github.io/concepts/manipulation/index.html)
