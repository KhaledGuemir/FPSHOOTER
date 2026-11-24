extends StaticBody3D

@export var max_health: float = 100.0
var current_health: float = 100.0

@onready var mesh: Node3D = $MeshInstance

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	current_health -= amount
	# Visual hit flash
	var orig_scale = scale
	scale = orig_scale * 1.15
	var tween = create_tween()
	tween.tween_property(self, "scale", orig_scale, 0.15)
	
	if current_health <= 0:
		destroy_target()

func destroy_target() -> void:
	# Spawn explosion effect
	var effect_scene = preload("res://scenes/impact_effect.tscn")
	var effect = effect_scene.instantiate()
	get_parent().add_child(effect)
	effect.global_position = global_position
	queue_free()
