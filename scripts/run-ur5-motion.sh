#!/bin/bash
# run-ur5-motion.sh - UR5/UR5eのモーション生成を実行
set -e

echo "=============================================="
echo "UR5 モーション生成スクリプト"
echo "=============================================="

CUROBO_DIR="/curobo/curobo"

# cuRoboインストール確認
if [ ! -d "$CUROBO_DIR" ]; then
    echo "エラー: cuRoboがインストールされていません。"
    echo "先に ./scripts/install-curobo.sh を実行してください。"
    exit 1
fi

cd "$CUROBO_DIR"

# デフォルト設定
ROBOT=${1:-"ur5e.yml"}
EXAMPLE=${2:-"motion_gen_reacher"}
EXTRA_ARGS="${@:3}"

# 使用可能なロボット設定を表示
show_robots() {
    echo ""
    echo "利用可能なロボット設定:"
    echo "  ur5e.yml           - Universal Robots UR5e"
    echo "  ur10e.yml          - Universal Robots UR10e"
    echo "  franka.yml         - Franka Panda"
    echo "  dual_ur10e.yml     - Dual UR10e (デュアルアーム)"
    echo ""
}

# 使用可能なサンプルを表示
show_examples() {
    echo ""
    echo "利用可能なサンプル:"
    echo "  motion_gen_reacher  - モーション生成（ターゲット追従）"
    echo "  ik_reachability     - IK到達可能性解析"
    echo "  mpc_example         - モデル予測制御"
    echo "  collision_checker   - 衝突チェッカー"
    echo "  multi_arm_reacher   - マルチアーム到達"
    echo ""
}

# ヘルプ表示
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo ""
    echo "使用方法: $0 [robot] [example] [extra_args...]"
    echo ""
    echo "引数:"
    echo "  robot       - ロボット設定ファイル（デフォルト: ur5e.yml）"
    echo "  example     - 実行するサンプル（デフォルト: motion_gen_reacher）"
    echo "  extra_args  - 追加の引数"
    show_robots
    show_examples
    echo "例:"
    echo "  $0                              # UR5eでモーション生成"
    echo "  $0 ur10e.yml                    # UR10eでモーション生成"
    echo "  $0 ur5e.yml ik_reachability     # UR5eでIK解析"
    echo "  $0 franka.yml motion_gen_reacher --visualize_spheres"
    echo ""
    exit 0
fi

# カスタム設定ファイルの確認
CUSTOM_CONFIG="/configs/ur5e_custom.yml"
if [ -f "$CUSTOM_CONFIG" ] && [ "$ROBOT" == "ur5e_custom.yml" ]; then
    echo "カスタム設定を使用: $CUSTOM_CONFIG"
    ROBOT_PATH="$CUSTOM_CONFIG"
else
    ROBOT_PATH="$ROBOT"
fi

echo ""
echo "実行設定:"
echo "  Robot: $ROBOT_PATH"
echo "  Example: $EXAMPLE"
echo "  Extra Args: $EXTRA_ARGS"
echo ""

# サンプルスクリプトのパス
SCRIPT_PATH="examples/isaac_sim/${EXAMPLE}.py"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "エラー: スクリプトが見つかりません: $SCRIPT_PATH"
    show_examples
    exit 1
fi

echo "起動中... (Isaac Simの初回起動は数分かかります)"
echo ""
echo "操作方法:"
echo "  - Playボタンをクリックしてシミュレーション開始"
echo "  - 赤いキューブをドラッグしてターゲット位置を変更"
echo "  - アセットブラウザからオブジェクトをドラッグ&ドロップで障害物追加"
echo "  - Ctrl+C で終了"
echo ""

# 実行
python "$SCRIPT_PATH" --robot "$ROBOT_PATH" $EXTRA_ARGS
