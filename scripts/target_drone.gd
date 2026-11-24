extends CharacterBody3D

@export var max_health: float = 100.0
@export var float_speed: float = 2.0
@export var patrol_range: float = 4.0
@export var points_reward: int = 100

var current_health: float = 100.0
var initial_pos: Vector3
var time_elapsed: float = 0.0
var move_dir: int = 1

@onready var mesh: Node3D = $MeshInstance

func _ready() -> void:
	current_health = max_health
	initial_pos = global_position
	# Random phase offset for natural motion
	time_elapsed = randf_range(0.0, 5.0)

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	# Floating bob and strafe motion
	var target_x = initial_pos.x + sin(time_elapsed * float_speed) * patrol_range
	var target_y = initial_pos.y + sin(time_elapsed * 3.0) * 0.4
	global_position.x = move_toward(global_position.x, target_x, delta * 3.5)
	global_position.y = move_toward(global_position.y, target_y, delta * 2.0)

func take_damage(amount: float) -> void:
	current_health -= amount
	# Visual hit flash & scale punch
	var orig_scale = Vector3.ONE
	scale = orig_scale * 1.2
	var tween = create_tween()
	tween.tween_property(self, "scale", orig_scale, 0.12)
	
	if current_health <= 0:
		destroy_target()

func destroy_target() -> void:
	# Add score to player
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("add_score"):
		player.add_score(points_reward)

	# Spawn explosion effect
	var effect_scene = preload("res://scenes/impact_effect.tscn")
	var effect = effect_scene.instantiate()
	get_parent().add_child(effect)
	effect.global_position = global_position
	queue_free()
