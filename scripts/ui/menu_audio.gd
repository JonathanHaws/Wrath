extends AudioStreamPlayer2D
@export var hover_sound: AudioStream
@export var press_sound: AudioStream
@export var hover_targets: Array[Node]
@export var pressed_targets: Array[Node]

func _on_mouse_entered() -> void:
	if not is_inside_tree(): return
	stream = hover_sound
	playing = true
	
func _on_pressed() -> void:
	if not is_inside_tree(): return
	stream = press_sound
	playing = true

func _connect_signals() -> void:
	for node in hover_targets:
		if node and node.has_signal("mouse_entered"):
			node.connect("mouse_entered", _on_mouse_entered)
			
	for node in pressed_targets:
		if node and node.has_signal("pressed"):
			node.connect("pressed", _on_pressed)
			
func _ready() -> void:
	call_deferred("_connect_signals")
	
