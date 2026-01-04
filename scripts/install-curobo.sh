#!/bin/bash
# install-curobo.sh - cuRoboをIsaac Sim環境にインストール
set -e

echo "=============================================="
echo "cuRobo インストールスクリプト"
echo "=============================================="

# cuRoboディレクトリ
CUROBO_DIR="/curobo"

# 既にインストール済みか確認
if [ -d "$CUROBO_DIR/curobo" ] && [ -f "$CUROBO_DIR/curobo/setup.py" ]; then
    echo "cuRoboは既にインストールされています。"
    echo ""
    read -p "再インストールしますか？ (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "インストールをスキップします。"
        exit 0
    fi
    rm -rf "$CUROBO_DIR/curobo"
fi

# 1. 依存パッケージのインストール
echo ""
echo "[1/4] 依存パッケージをインストール中..."
pip install --upgrade pip
pip install tomli wheel ninja

# git lfsのインストール（必要な場合）
if ! command -v git-lfs &> /dev/null; then
    echo "git-lfs をインストール中..."
    apt-get update && apt-get install -y git-lfs
fi
git lfs install

# 2. cuRoboのクローン
echo ""
echo "[2/4] cuRoboリポジトリをクローン中..."
cd "$CUROBO_DIR"
git clone https://github.com/NVlabs/curobo.git
cd curobo

# 3. cuRoboのインストール
echo ""
echo "[3/4] cuRoboをインストール中（数分かかります）..."
pip install -e ".[isaacsim]" --no-build-isolation

# 4. インストール確認
echo ""
echo "[4/4] インストールを確認中..."

python -c "
import curobo
print(f'cuRobo version: {curobo.__version__}')
from curobo.types.robot import RobotConfig
print('RobotConfig imported successfully')
from curobo.wrap.reacher.motion_gen import MotionGen
print('MotionGen imported successfully')
print('')
print('cuRobo installation verified!')
"

# 5. UR5e設定の確認
echo ""
echo "利用可能なロボット設定:"
ls -la "$CUROBO_DIR/curobo/src/curobo/content/configs/robot/" | grep -E "ur|franka"

echo ""
echo "=============================================="
echo "cuRobo インストール完了！"
echo "=============================================="
echo ""
echo "使用例:"
echo ""
echo "  # UR5eでモーション生成（Isaac Sim UI付き）"
echo "  cd $CUROBO_DIR/curobo"
echo "  python examples/isaac_sim/motion_gen_reacher.py --robot ur5e.yml --visualize_spheres"
echo ""
echo "  # Franka Pandaでモーション生成"
echo "  python examples/isaac_sim/motion_gen_reacher.py --robot franka.yml"
echo ""
echo "  # IK到達可能性デモ"
echo "  python examples/isaac_sim/ik_reachability.py --robot ur5e.yml"
echo ""
