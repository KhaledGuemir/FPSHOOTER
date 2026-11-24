import bpy
import os

out_dir = r"D:\games\fpshooter\assets\models"
os.makedirs(out_dir, exist_ok=True)

def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def make_material(name, diffuse_color, metallic=0.1, roughness=0.5, emission=None):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = diffuse_color
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
        if emission:
            # Handle emission depending on blender version input names
            if "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission
                bsdf.inputs["Emission Strength"].default_value = 2.0
            elif "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission
    return mat

# --- 1. PISTOL ---
reset_scene()
mat_dark = make_material("GunMetal", (0.12, 0.13, 0.15, 1.0), metallic=0.9, roughness=0.3)
mat_grip = make_material("GripPolymer", (0.05, 0.05, 0.06, 1.0), metallic=0.1, roughness=0.8)
mat_accent = make_material("AccentGlow", (0.1, 0.7, 1.0, 1.0), emission=(0.1, 0.7, 1.0, 1.0))

# Slide
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.05, 0.12))
slide = bpy.context.active_object
slide.name = "Pistol_Slide"
slide.scale = (0.08, 0.35, 0.09)
slide.data.materials.append(mat_dark)

# Grip
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.07, -0.02))
grip = bpy.context.active_object
grip.name = "Pistol_Grip"
grip.scale = (0.07, 0.12, 0.22)
grip.rotation_euler = (0.2, 0, 0)
grip.data.materials.append(mat_grip)

# Barrel
bpy.ops.mesh.primitive_cylinder_add(radius=0.025, depth=0.1, location=(0, 0.23, 0.12), rotation=(1.5708, 0, 0))
barrel = bpy.context.active_object
barrel.name = "Pistol_Barrel"
barrel.data.materials.append(mat_dark)

# Sight glow
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.21, 0.17))
sight = bpy.context.active_object
sight.name = "Pistol_Sight"
sight.scale = (0.015, 0.02, 0.02)
sight.data.materials.append(mat_accent)

# Export Pistol
bpy.ops.export_scene.gltf(filepath=os.path.join(out_dir, "pistol.glb"), export_format='GLB')

# --- 2. RIFLE ---
reset_scene()
mat_rifle_body = make_material("RifleBody", (0.18, 0.19, 0.2, 1.0), metallic=0.8, roughness=0.4)
mat_rifle_stock = make_material("RifleStock", (0.08, 0.08, 0.09, 1.0), metallic=0.2, roughness=0.7)
mat_rifle_orange = make_material("RifleOrange", (1.0, 0.35, 0.05, 1.0), emission=(1.0, 0.35, 0.05, 1.0))

# Body
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.1, 0.05))
r_body = bpy.context.active_object
r_body.name = "Rifle_Body"
r_body.scale = (0.09, 0.6, 0.12)
r_body.data.materials.append(mat_rifle_body)

# Long Barrel
bpy.ops.mesh.primitive_cylinder_add(radius=0.03, depth=0.45, location=(0, 0.55, 0.06), rotation=(1.5708, 0, 0))
r_barrel = bpy.context.active_object
r_barrel.name = "Rifle_Barrel"
r_barrel.data.materials.append(mat_rifle_body)

# Handguard / Shroud
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.42, 0.06))
r_shroud = bpy.context.active_object
r_shroud.scale = (0.08, 0.28, 0.09)
r_shroud.data.materials.append(mat_rifle_stock)

# Stock
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.32, 0.02))
r_stock = bpy.context.active_object
r_stock.name = "Rifle_Stock"
r_stock.scale = (0.07, 0.3, 0.14)
r_stock.data.materials.append(mat_rifle_stock)

# Grip
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.06, -0.12))
r_grip = bpy.context.active_object
r_grip.name = "Rifle_Grip"
r_grip.scale = (0.06, 0.1, 0.2)
r_grip.rotation_euler = (0.25, 0, 0)
r_grip.data.materials.append(mat_rifle_stock)

# Magazine (Curved / angled)
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.12, -0.15))
r_mag = bpy.context.active_object
r_mag.name = "Rifle_Mag"
r_mag.scale = (0.06, 0.12, 0.24)
r_mag.rotation_euler = (-0.2, 0, 0)
r_mag.data.materials.append(mat_rifle_stock)

# Scope
bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.3, location=(0, 0.05, 0.16), rotation=(1.5708, 0, 0))
r_scope = bpy.context.active_object
r_scope.name = "Rifle_Scope"
r_scope.data.materials.append(mat_rifle_body)

# Scope Lens
bpy.ops.mesh.primitive_cylinder_add(radius=0.03, depth=0.02, location=(0, 0.2, 0.16), rotation=(1.5708, 0, 0))
r_lens = bpy.context.active_object
r_lens.data.materials.append(mat_rifle_orange)

bpy.ops.export_scene.gltf(filepath=os.path.join(out_dir, "rifle.glb"), export_format='GLB')

# --- 3. CITY BUILDINGS & PROPS ---
# Building 1: Tall Skyscraper
reset_scene()
mat_glass = make_material("TowerGlass", (0.1, 0.2, 0.3, 1.0), metallic=0.7, roughness=0.1)
mat_concrete = make_material("Concrete", (0.55, 0.53, 0.5, 1.0), metallic=0.0, roughness=0.9)
mat_windows_lit = make_material("SunsetWindows", (1.0, 0.7, 0.3, 1.0), emission=(1.0, 0.6, 0.2, 1.0))

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 20.0))
b1 = bpy.context.active_object
b1.scale = (12.0, 12.0, 40.0)
b1.data.materials.append(mat_glass)

# Roof structure
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 41.5))
b1_roof = bpy.context.active_object
b1_roof.scale = (8.0, 8.0, 3.0)
b1_roof.data.materials.append(mat_concrete)

bpy.ops.export_scene.gltf(filepath=os.path.join(out_dir, "building_tower.glb"), export_format='GLB')

# Building 2: Mid-rise Commercial Building
reset_scene()
mat_brick = make_material("BrickWall", (0.6, 0.35, 0.25, 1.0), metallic=0.0, roughness=0.95)
mat_trim = make_material("DarkTrim", (0.2, 0.2, 0.22, 1.0), metallic=0.3, roughness=0.6)

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 10.0))
b2 = bpy.context.active_object
b2.scale = (16.0, 14.0, 20.0)
b2.data.materials.append(mat_brick)

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 20.2))
b2_rim = bpy.context.active_object
b2_rim.scale = (16.4, 14.4, 0.6)
b2_rim.data.materials.append(mat_trim)

bpy.ops.export_scene.gltf(filepath=os.path.join(out_dir, "building_mid.glb"), export_format='GLB')

# Prop 1: Street Light
reset_scene()
mat_pole = make_material("MetalPole", (0.15, 0.16, 0.18, 1.0), metallic=0.8, roughness=0.3)
mat_light = make_material("StreetLampWarm", (1.0, 0.85, 0.5, 1.0), emission=(1.0, 0.85, 0.5, 1.0))

bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=6.0, location=(0, 0, 3.0))
pole = bpy.context.active_object
pole.data.materials.append(mat_pole)

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.8, 5.9))
arm = bpy.context.active_object
arm.scale = (0.2, 1.8, 0.2)
arm.data.materials.append(mat_pole)

bpy.ops.mesh.primitive_cone_add(radius1=0.4, depth=0.3, location=(0, 1.5, 5.75))
lamp_head = bpy.context.active_object
lamp_head.data.materials.append(mat_light)

bpy.ops.export_scene.gltf(filepath=os.path.join(out_dir, "street_light.glb"), export_format='GLB')

# Prop 2: Urban Barrier / Crate
reset_scene()
mat_barrier = make_material("ConcreteBarrier", (0.65, 0.62, 0.58, 1.0), metallic=0.0, roughness=0.9)
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.6))
barrier = bpy.context.active_object
barrier.scale = (2.5, 0.6, 1.2)
barrier.data.materials.append(mat_barrier)
bpy.ops.export_scene.gltf(filepath=os.path.join(out_dir, "barrier.glb"), export_format='GLB')

# Prop 3: Target / Enemy Robot
reset_scene()
mat_bot = make_material("BotArmor", (0.8, 0.2, 0.2, 1.0), metallic=0.6, roughness=0.4)
mat_eye = make_material("BotEye", (0.2, 1.0, 0.3, 1.0), emission=(0.2, 1.0, 0.3, 1.0))

# Torso
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.2))
bot_body = bpy.context.active_object
bot_body.scale = (0.7, 0.4, 0.9)
bot_body.data.materials.append(mat_bot)

# Head
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.95))
bot_head = bpy.context.active_object
bot_head.scale = (0.45, 0.4, 0.4)
bot_head.data.materials.append(mat_bot)

# Eye
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.21, 1.95))
bot_eye = bpy.context.active_object
bot_eye.scale = (0.3, 0.05, 0.1)
bot_eye.data.materials.append(mat_eye)

bpy.ops.export_scene.gltf(filepath=os.path.join(out_dir, "target_drone.glb"), export_format='GLB')

print("All GLB assets exported successfully!")
