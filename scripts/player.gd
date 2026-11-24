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

# Audio players
@onready var audio_pistol: AudioStreamPlayer3D = $Head/Camera3D/GunContainer/Pistol/AudioPistol
@onready var audio_rifle: AudioStreamPlayer3D = $Head/Camera3D/GunContainer/Rifle/AudioRifle
@onready var audio_reload: AudioStreamPlayer = $AudioReload
@onready var audio_switch: AudioStreamPlayer = $AudioSwitch

# HUD elements
@onready var hud_weapon: Label = $HUD/WeaponLabel
@onready var hud_ammo: Label = $HUD/AmmoLabel
@onready var hud_score: Label = $HUD/ScoreLabel
@onready var hud_health: Label = $HUD/HealthBar/Label
@onready var health_progress: ProgressBar = $HUD/HealthBar
@onready var pause_menu: Control = $HUD/PauseMenu

var current_weapon: int = 1 # 1: Pistol, 2: Rifle
var pistol_ammo: int = 12
var pistol_max_ammo: int = 12
var rifle_ammo: int = 30
var rifle_max_ammo: int = 30
var fire_rate_timer: float = 0.0
var pistol_cooldown: float = 0.22
var rifle_cooldown: float = 0.09
var default_gun_pos: Vector3 = Vector3.ZERO
var player_health: float = 100.0
var max_player_health: float = 100.0
var score: int = 0
var is_reloading: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	switch_weapon(1)
	if gun_container:
		default_gun_pos = gun_container.position
	update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

	if pause_menu.visible:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("switch_gun_1") and current_weapon != 1:
		switch_weapon(1)
	elif event.is_action_pressed("switch_gun_2") and current_weapon != 2:
		switch_weapon(2)

	if event.is_action_pressed("reload") and not is_reloading:
		start_reload()

func _physics_process(delta: float) -> void:
	if pause_menu.visible:
		return

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
	if not is_reloading:
		if current_weapon == 1:
			if Input.is_action_just_pressed("fire") and fire_rate_timer <= 0.0:
				shoot_pistol()
		elif current_weapon == 2:
			if Input.is_action_pressed("fire") and fire_rate_timer <= 0.0:
				shoot_rifle()

func toggle_pause() -> void:
	var paused = not pause_menu.visible
	pause_menu.visible = paused
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func switch_weapon(weapon_id: int) -> void:
	current_weapon = weapon_id
	if audio_switch:
		audio_switch.play()

	if current_weapon == 1:
		pistol_node.visible = true
		rifle_node.visible = false
		hud_weapon.text = "WEAPON: [1] PISTOL (SEMI-AUTO)"
	else:
		pistol_node.visible = false
		rifle_node.visible = true
		hud_weapon.text = "WEAPON: [2] ASSAULT RIFLE (AUTO)"
	update_hud()

func start_reload() -> void:
	if (current_weapon == 1 and pistol_ammo == pistol_max_ammo) or (current_weapon == 2 and rifle_ammo == rifle_max_ammo):
		return
	is_reloading = true
	if audio_reload:
		audio_reload.play()
	hud_ammo.text = "RELOADING..."
	await get_tree().create_timer(0.55).timeout
	if current_weapon == 1:
		pistol_ammo = pistol_max_ammo
	else:
		rifle_ammo = rifle_max_ammo
	is_reloading = false
	update_hud()

func update_hud() -> void:
	if current_weapon == 1:
		hud_ammo.text = "AMMO: %d / %d" % [pistol_ammo, pistol_max_ammo]
	else:
		hud_ammo.text = "AMMO: %d / %d" % [rifle_ammo, rifle_max_ammo]
	hud_score.text = "SCORE: %d" % score
	health_progress.value = player_health
	hud_health.text = "HEALTH: %d / %d" % [int(player_health), int(max_player_health)]

func shoot_pistol() -> void:
	if pistol_ammo <= 0:
		start_reload()
		return
	pistol_ammo -= 1
	fire_rate_timer = pistol_cooldown
	update_hud()

	if audio_pistol:
		audio_pistol.pitch_scale = randf_range(0.95, 1.05)
		audio_pistol.play()

	trigger_muzzle_effects(muzzle_flash_pistol, particles_pistol, 0.07, 0.04)
	perform_raycast(35.0)

func shoot_rifle() -> void:
	if rifle_ammo <= 0:
		start_reload()
		return
	rifle_ammo -= 1
	fire_rate_timer = rifle_cooldown
	update_hud()

	if audio_rifle:
		audio_rifle.pitch_scale = randf_range(0.92, 1.08)
		audio_rifle.play()

	trigger_muzzle_effects(muzzle_flash_rifle, particles_rifle, 0.04, 0.055)
	perform_raycast(50.0)

func trigger_muzzle_effects(light: OmniLight3D, particles: GPUParticles3D, duration: float, recoil_kick: float) -> void:
	# Recoil animation
	if gun_container:
		gun_container.position.z += recoil_kick
		gun_container.rotation.x += recoil_kick * 0.8
		var tween = create_tween().set_parallel(true)
		tween.tween_property(gun_container, "rotation:x", 0.0, duration * 2.5)

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
		
		# Spawn impact spark VFX & sound
		spawn_impact_effect(hit_pos, hit_normal)
		
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)

func add_score(pts: int) -> void:
	score += pts
	update_hud()

func take_damage(amount: float) -> void:
	player_health = max(player_health - amount, 0.0)
	update_hud()
	# Camera shake
	var shake_tween = create_tween()
	head.position.y += 0.05
	shake_tween.tween_property(head, "position:y", 1.65, 0.15)
	if player_health <= 0:
		# Respawn
		player_health = max_player_health
		global_position = Vector3(0, 0.5, 5)
		update_hud()

func spawn_impact_effect(pos: Vector3, normal: Vector3) -> void:
	var effect_scene = preload("res://scenes/impact_effect.tscn")
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = pos
	if normal.length_squared() > 0.001 and not normal.is_equal_approx(Vector3.UP):
		effect.look_at(pos + normal, Vector3.UP)
