extends Node
## Group containing the Label whos advacement controls playback...
## Could also be used to use different sounds for different emotions eg. (angry_chat_label, sad_chat_label) etc
@export var chat_group := "chat" 
@export var character_delta := 3 ## How many characters the label has to advance to trigger a new random sound
@export var pitch_min := 0.8 ## Monimum pitch modulation
@export var pitch_max := 1.2 ## Maximum pitch modulation
@export var sounds: Array[AudioStream] = []
@export var player: AudioStreamPlayer
var last_visible := 0
var label: Label

func _process(_delta):
	#print('test')
	var new_label = get_tree().get_first_node_in_group(chat_group) # Will dynamically detect new labels 
	if new_label != label: last_visible = 0
	label = new_label

	if not label or not player: return
	if label.visible_characters > label.text.length(): return
	if label.visible_characters - last_visible < character_delta: return

	if sounds.size() > 0:
		player.stream = sounds[randi() % sounds.size()]

	player.pitch_scale = randf_range(pitch_min, pitch_max)
	player.play()
	last_visible = label.visible_characters
