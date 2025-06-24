extends Node
@export var destination_scene: PackedScene

func _ready() -> void:
	connect("pressed", _on_quit_to_menu_pressed)

func _on_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(destination_scene)
