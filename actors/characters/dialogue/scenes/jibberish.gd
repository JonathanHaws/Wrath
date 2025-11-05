extends AudioStreamPlayer

@export var label: Label
@export var character_delta: int = 3
@export var pitch_min: float = 0.8
@export var pitch_max: float = 1.2
var last_visible := 0

func _process(_delta):
	if not label: return
	if label.visible_characters > label.text.length(): return
	
	if label.visible_characters - last_visible >= character_delta:
		pitch_scale = randf_range(pitch_min, pitch_max)
		play()
		last_visible = label.visible_characters
