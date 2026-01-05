import numpy as np
import omni.kit.app
from isaacsim.core.prims import SingleArticulation as Articulation
from isaacsim.core.prims import SingleXFormPrim as XFormPrim
from isaacsim.robot_motion.motion_generation import RmpFlow, ArticulationMotionPolicy
from isaacsim.robot_motion.motion_generation.interface_config_loader import load_supported_motion_policy_config

# ロボットとターゲットを取得
robot = Articulation("/World/UR5e")
robot.initialize()
target = XFormPrim("/World/target", scale=[0.04, 0.04, 0.04])

# RMPflowを初期化
rmp_config = load_supported_motion_policy_config("UR5e", "RMPflow")
rmpflow = RmpFlow(**rmp_config)
articulation_policy = ArticulationMotionPolicy(robot, rmpflow)

# ターゲット位置を設定
target_position = np.array([0.4, 0.2, 0.5])
target_orientation = np.array([0, 1, 0, 0])
target.set_world_pose(target_position, target_orientation)

print(f"Target: {target_position}")

# グローバル変数
step_count = 0
max_steps = 300
sub = None

def on_physics_step(dt):
    global step_count, sub
    
    if step_count >= max_steps:
        if sub is not None:
            sub.unsubscribe()
            sub = None
        print("Motion complete!")
        return
    
    # ターゲット位置を取得
    target_pos, target_ori = target.get_world_pose()
    
    # RMPflowにターゲットを設定
    rmpflow.set_end_effector_target(target_pos, target_ori)
    rmpflow.update_world()
    
    # ロボットベース位置を更新
    robot_base_pos, robot_base_ori = robot.get_world_pose()
    rmpflow.set_robot_base_pose(robot_base_pos, robot_base_ori)
    
    # アクションを計算して適用
    action = articulation_policy.get_next_articulation_action(dt)
    robot.apply_action(action)
    
    if step_count % 50 == 0:
        print(f"Step {step_count}")
    
    step_count += 1

# 物理ステップにコールバックを登録
import omni.physx
physx_interface = omni.physx.get_physx_interface()
sub = physx_interface.subscribe_physics_step_events(on_physics_step)

print("RMPflow motion started!")