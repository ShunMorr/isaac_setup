#!/bin/bash
# install-curobo.sh - cuRoboをIsaac Sim環境にインストール
# このスクリプトはコンテナ内で実行します

set -e

echo "=============================================="
echo "cuRobo インストール"
echo "=============================================="

# cuRoboディレクトリ確認
if [ ! -d "/curobo" ]; then
    echo "エラー: /curobo ディレクトリが見つかりません"
    echo "setup.shを実行してからコンテナを起動してください"
    exit 1
fi

# 既にインストール済みか確認
if /isaac-sim/python.sh -c "import curobo" 2>/dev/null; then
    echo "cuRoboは既にインストールされています"
    /isaac-sim/python.sh -c "import curobo; print(f'cuRobo version: {curobo.__version__}')"
    exit 0
fi

echo ""
echo "[1/3] 依存パッケージをインストール中..."
/isaac-sim/python.sh -m pip install tomli wheel ninja

echo ""
echo "[2/3] cuRoboをインストール中（数分かかります）..."
cd /curobo
/isaac-sim/python.sh -m pip install -e ".[isaacsim]" --no-build-isolation

echo ""
echo "[3/3] インストールを確認中..."
/isaac-sim/python.sh -c "
import curobo
print(f'cuRobo version: {curobo.__version__}')
from curobo.types.robot import RobotConfig
print('RobotConfig imported successfully')
from curobo.wrap.reacher.motion_gen import MotionGen
print('MotionGen imported successfully')
"

echo ""
echo "=============================================="
echo "cuRobo インストール完了！"
echo "=============================================="
echo ""
echo "使用例:"
echo ""
echo "  # UR5eでモーション生成"
echo "  cd /curobo"
echo "  /isaac-sim/python.sh examples/isaac_sim/motion_gen_reacher.py --robot ur5e.yml"
echo ""
echo "  # 衝突球を可視化"
echo "  /isaac-sim/python.sh examples/isaac_sim/motion_gen_reacher.py --robot ur5e.yml --visualize_spheres"
echo ""
