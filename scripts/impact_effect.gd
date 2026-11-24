extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var light: OmniLight3D = $OmniLight3D
@onready var audio_hit: AudioStreamPlayer3D = $AudioHit

func _ready() -> void:
	particles.emitting = true
	if audio_hit:
		audio_hit.pitch_scale = randf_range(0.9, 1.2)
		audio_hit.play()
	var tween = create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.3)
	await get_tree().create_timer(0.6).timeout
	queue_free()
