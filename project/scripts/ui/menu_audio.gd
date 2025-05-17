extends AudioStreamPlayer2D
@export var hover_sound: AudioStream
@export var press_sound: AudioStream
@export var hover_targets: Array[Node]
@export var pressed_targets: Array[Node]

func _on_mouse_entered() -> void:
	stream = hover_sound
	playing = true
	
func _on_pressed() -> void:
	stream = press_sound
	playing = true

func _ready() -> void:
	for node in hover_targets:
		if node and node.has_signal("mouse_entered"):
			node.connect("mouse_entered", _on_mouse_entered)
		else:
			print('doesnt have one')
			
	for node in pressed_targets:
		if node and node.has_signal("pressed"):
			node.connect("pressed", _on_pressed)

	
