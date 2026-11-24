extends CharacterBody3D

@export var speed: float = 6.0
@export var sprint_speed: float = 9.5
@export var jump_velocity: float = 4.8
@export var mouse_sensitivity: float = 0.0025

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var gun_container: Node3D = $Head/Camera3D/GunContainer
@onready var pistol_node: Node3D = $Head/Camera3D/GunContainer/Pistol
@onready var rifle_node: Node3D = $Head/Camera3D/GunContainer/Rifle
@onready var muzzle_flash_pistol: OmniLight3D = $Head/Camera3D/GunContainer/Pistol/MuzzleLight
@onready var muzzle_flash_rifle: OmniLight3D = $Head/Camera3D/GunContainer/Rifle/MuzzleLight
@onready var particles_pistol: GPUParticles3D = $Head/Camera3D/GunContainer/Pistol/FlashParticles
@onready var particles_rifle: GPUParticles3D = $Head/Camera3D/GunContainer/Rifle/FlashParticles
@onready var hud_weapon: Label = $HUD/WeaponLabel
@onready var hud_ammo: Label = $HUD/AmmoLabel
@onready var crosshair: Control = $HUD/Crosshair

var current_weapon: int = 1 # 1: Pistol, 2: Rifle
var pistol_ammo: int = 12
var pistol_max_ammo: int = 12
var rifle_ammo: int = 30
var rifle_max_ammo: int = 30
var fire_rate_timer: float = 0.0
var pistol_cooldown: float = 0.22
var rifle_cooldown: float = 0.1
var default_gun_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	switch_weapon(1)
	if gun_container:
		default_gun_pos = gun_container.position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("switch_gun_1"):
		switch_weapon(1)
	elif event.is_action_pressed("switch_gun_2"):
		switch_weapon(2)

	if event.is_action_pressed("reload"):
		reload_weapon()

func _physics_process(delta: float) -> void:
	# Cooldown timer
	if fire_rate_timer > 0.0:
		fire_rate_timer -= delta

	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Speed
	var current_speed = sprint_speed if Input.is_key_pressed(KEY_SHIFT) else speed

	# Movement vector
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

	# Gun sway and recoil recovery
	if gun_container:
		gun_container.position = gun_container.position.lerp(default_gun_pos, delta * 12.0)

	# Firing
	if current_weapon == 1:
		if Input.is_action_just_pressed("fire") and fire_rate_timer <= 0.0:
			shoot_pistol()
	elif current_weapon == 2:
		if Input.is_action_pressed("fire") and fire_rate_timer <= 0.0:
			shoot_rifle()

func switch_weapon(weapon_id: int) -> void:
	current_weapon = weapon_id
	if current_weapon == 1:
		pistol_node.visible = true
		rifle_node.visible = false
		hud_weapon.text = "WEAPON: [1] PISTOL (SEMI-AUTO)"
		update_ammo_display()
	else:
		pistol_node.visible = false
		rifle_node.visible = true
		hud_weapon.text = "WEAPON: [2] ASSAULT RIFLE (AUTO)"
		update_ammo_display()

func reload_weapon() -> void:
	if current_weapon == 1:
		pistol_ammo = pistol_max_ammo
	else:
		rifle_ammo = rifle_max_ammo
	update_ammo_display()

func update_ammo_display() -> void:
	if current_weapon == 1:
		hud_ammo.text = "AMMO: %d / %d" % [pistol_ammo, pistol_max_ammo]
	else:
		hud_ammo.text = "AMMO: %d / %d" % [rifle_ammo, rifle_max_ammo]

func shoot_pistol() -> void:
	if pistol_ammo <= 0:
		reload_weapon()
		return
	pistol_ammo -= 1
	fire_rate_timer = pistol_cooldown
	update_ammo_display()

	trigger_muzzle_effects(muzzle_flash_pistol, particles_pistol, 0.07, 0.04)
	perform_raycast(25.0)

func shoot_rifle() -> void:
	if rifle_ammo <= 0:
		reload_weapon()
		return
	rifle_ammo -= 1
	fire_rate_timer = rifle_cooldown
	update_ammo_display()

	trigger_muzzle_effects(muzzle_flash_rifle, particles_rifle, 0.04, 0.06)
	perform_raycast(45.0)

func trigger_muzzle_effects(light: OmniLight3D, particles: GPUParticles3D, duration: float, recoil_kick: float) -> void:
	# Recoil animation
	if gun_container:
		gun_container.position.z += recoil_kick
		gun_container.rotation.x += recoil_kick * 0.8
		var tween = create_tween().set_parallel(true)
		tween.tween_property(gun_container, "rotation:x", 0.0, duration * 2.0)

	# Muzzle light flash
	if light:
		light.visible = true
		var timer = get_tree().create_timer(duration)
		timer.timeout.connect(func(): if is_instance_valid(light): light.visible = false)

	# Particle spark burst
	if particles:
		particles.restart()
		particles.emitting = true

func perform_raycast(damage: float) -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var hit_pos = raycast.get_collision_point()
		var hit_normal = raycast.get_collision_normal()
		
		# Spawn impact spark VFX
		spawn_impact_effect(hit_pos, hit_normal)
		
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)

func spawn_impact_effect(pos: Vector3, normal: Vector3) -> void:
	var effect_scene = preload("res://scenes/impact_effect.tscn")
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = pos
	if normal.length_squared() > 0.001 and not normal.is_equal_approx(Vector3.UP):
		effect.look_at(pos + normal, Vector3.UP)
