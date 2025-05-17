extends Node
var hover_player: AudioStreamPlayer2D
var press_player: AudioStreamPlayer2D
var hover_sound: AudioStream
var press_sound: AudioStream

func _ready() -> void:
	hover_player = $HoverPlayer
	press_player = $PressPlayer
	var button := $Button
	button.connect("mouse_entered", _on_hovered)
	button.connect("pressed", _on_pressed)

func _on_hovered() -> void:
	if not hover_player.is_inside_tree(): return
	hover_player.stream = hover_sound
	hover_player.play()

func _on_pressed() -> void:
	if not press_player.is_inside_tree(): return
	press_player.stream = press_sound
	press_player.play()
