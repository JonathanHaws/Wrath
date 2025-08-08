extends Button
@export_file("*.tscn") var scene_file: String
## if no node to replace is specified will replace the entire tree
@export var node_to_replace: Node

var scene = null

func _ready() -> void:
	if scene_file != "" and ResourceLoader.exists(scene_file):
		scene = load(scene_file)
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if not scene: return

	if node_to_replace:
		var parent = node_to_replace.get_parent()
		node_to_replace.queue_free()
		parent.add_child(scene.instantiate())
	else:
		get_tree().change_scene_to_packed(scene)
