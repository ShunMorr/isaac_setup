import numpy as np
import omni.physx
from isaacsim.core.api.world import World
from isaacsim.core.utils.stage import add_reference_to_stage
from isaacsim.core.prims import SingleArticulation as Articulation
from isaacsim.core.prims import SingleXFormPrim as XFormPrim
from isaacsim.storage.native import get_assets_root_path
from isaacsim.robot_motion.motion_generation import RmpFlow, ArticulationMotionPolicy
from isaacsim.robot_motion.motion_generation.interface_config_loader import load_supported_motion_policy_config

# === ステージセットアップ ===
world = World(stage_units_in_meters=1.0)
world.scene.add_default_ground_plane()

# UR5eを追加
assets_root = get_assets_root_path()
ur5e_path = assets_root + "/Isaac/Robots/UniversalRobots/ur5e/ur5e.usd"
add_reference_to_stage(usd_path=ur5e_path, prim_path="/World/UR5e")

# ターゲットを追加
add_reference_to_stage(assets_root + "/Isaac/Props/UIElements/frame_prim.usd", "/World/target")

print("Stage setup complete")

# グローバル変数
initialized = False
step_count = 0
max_steps = 300
physics_sub = None
robot = None
target = None
rmpflow = None
articulation_policy = None

def initialize_rmpflow():
    global robot, target, rmpflow, articulation_policy, initialized
    
    robot = world.scene.add(Articulation(prim_path="/World/UR5e", name="ur5e"))
    target = XFormPrim("/World/target", scale=[0.04, 0.04, 0.04])
    
    rmp_config = load_supported_motion_policy_config("UR5e", "RMPflow")
    rmpflow = RmpFlow(**rmp_config)
    articulation_policy = ArticulationMotionPolicy(robot, rmpflow)
    
    target_position = np.array([0.4, 0.2, 0.5])
    target_orientation = np.array([0, 1, 0, 0])
    target.set_world_pose(target_position, target_orientation)
    
    print(f"RMPflow initialized. Target: {target_position}")
    initialized = True

def on_physics_step(dt):
    global step_count, physics_sub, initialized
    
    if not initialized:
        return
    
    if step_count >= max_steps:
        if physics_sub is not None:
            physics_sub.unsubscribe()
            physics_sub = None
        print("Motion complete!")
        return
    
    target_pos, target_ori = target.get_world_pose()
    rmpflow.set_end_effector_target(target_pos, target_ori)
    rmpflow.update_world()
    
    robot_base_pos, robot_base_ori = robot.get_world_pose()
    rmpflow.set_robot_base_pose(robot_base_pos, robot_base_ori)
    
    action = articulation_policy.get_next_articulation_action(dt)
    robot.apply_action(action)
    
    if step_count % 50 == 0:
        print(f"Step {step_count}")
    
    step_count += 1

# 物理ステップにサブスクライブ
physx_interface = omni.physx.get_physx_interface()
physics_sub = physx_interface.subscribe_physics_step_events(on_physics_step)

# Worldをリセット
world.reset()

# RMPflowを初期化
initialize_rmpflow()

print("Simulation running!")