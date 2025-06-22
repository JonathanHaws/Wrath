extends Button

@export var scene_to_spawn_path: String
@export var node_to_replace: Node

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if node_to_replace:
		var parent = node_to_replace.get_parent()
		node_to_replace.queue_free()
		var scene = load(scene_to_spawn_path)
		if scene:
			var instance = scene.instantiate()
			parent.add_child(instance)
