extends Control

@onready var resume_btn: Button = $VBoxContainer/ResumeBtn
@onready var restart_btn: Button = $VBoxContainer/RestartBtn
@onready var quit_btn: Button = $VBoxContainer/QuitBtn
@onready var volume_slider: HSlider = $VBoxContainer/VolumeSlider

func _ready() -> void:
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	quit_btn.pressed.connect(_on_quit)
	volume_slider.value_changed.connect(_on_volume_changed)

func _on_resume() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("toggle_pause"):
		player.toggle_pause()
	else:
		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_restart() -> void:
	get_tree().reload_current_scene()

func _on_quit() -> void:
	get_tree().quit()

func _on_volume_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(val))
