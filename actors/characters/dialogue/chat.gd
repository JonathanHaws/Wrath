extends AnimationPlayer
@export var info: Array = []
@export var auto_play: bool = true
@export var auto_play_string: String = "entered"

@export_subgroup("Audio") 
@export var label: Label
@export var player: AudioStreamPlayer
@export var character_delta: int = 3
@export var pitch_min: float = 0.8
@export var pitch_max: float = 1.2
@export var sounds: Array[AudioStream] = [] ## Auto Generated Jibberish
var last_visible := 0
func audio_process() -> void:
	if not player: return
	if not label: return
	if label.visible_characters > label.text.length(): return

	if label.visible_characters - last_visible >= character_delta:
		
		if sounds.size() > 0:
			player.stream = sounds[randi() % sounds.size()]
		
		player.pitch_scale = randf_range(pitch_min, pitch_max)
		player.play()
		last_visible = label.visible_characters


func _ready():
	if info.size() > 0:
		label.text = info[0]
		
	if auto_play:
		play(auto_play_string)

func _process(_delta):
	audio_process()
	
	var parent = get_parent()
	if parent and "in_range" in parent:
		if not parent.in_range or Input.is_action_just_pressed("interact"):
			queue("exited")
