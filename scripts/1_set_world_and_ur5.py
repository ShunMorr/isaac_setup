import numpy as np
from isaacsim.core.api.world import World
from isaacsim.core.utils.stage import add_reference_to_stage
from isaacsim.storage.native import get_assets_root_path

# Worldを作成
world = World(stage_units_in_meters=1.0)
world.scene.add_default_ground_plane()

# UR5eを追加
assets_root = get_assets_root_path()
ur5e_path = assets_root + "/Isaac/Robots/UniversalRobots/ur5e/ur5e.usd"
add_reference_to_stage(usd_path=ur5e_path, prim_path="/World/UR5e")

# ターゲットを追加
add_reference_to_stage(assets_root + "/Isaac/Props/UIElements/frame_prim.usd", "/World/target")

print("Setup complete!")
print("Press PLAY, then run Step 2")