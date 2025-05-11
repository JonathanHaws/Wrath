
# Make sure process mode for this node is 'always' so when game pauses it doesnt pause aswell
extends CanvasLayer

@export_subgroup("Audio")
@export var hover_sound_player: AudioStreamPlayer2D
@export var press_sound_player: AudioStreamPlayer2D
@export var hover_sound: AudioStream
@export var press_sound: AudioStream
func _play_hover_sound() -> void:
	if not hover_sound_player.is_inside_tree(): return
	hover_sound_player.stream = hover_sound; 
	hover_sound_player.play()
func _play_press_sound() -> void:
	if not press_sound_player.is_inside_tree(): return
	press_sound_player.stream = press_sound; 
	press_sound_player.play()

@export_subgroup("Main Menu")
@export var main_menu: Control
@export var resume_button: Button
@export var restart_button: Button
@export var new_game_button: Button
@export var options_button: Button
@export var controls_button: Button
@export var credits_button: Button
@export var quit_button: Button
func _on_resume_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.visible = false
	Engine.time_scale = 1
	get_tree().paused = false
func _on_pause_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
	self.visible = true;
	Engine.time_scale = 0
	get_tree().paused = true

func _ready() -> void:
	_on_resume_pressed()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		#_check_for_window_changes()
		if self.visible:
			_on_resume_pressed()	
		else :
			_play_press_sound()
			_on_pause_pressed()
