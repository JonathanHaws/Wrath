extends Node # Can be used on anything but most likely button
@export_file("*.tscn") var scene_file: String
@export var node_to_replace: Node ## if no node to replace is specified will replace the entire tree (USUALLY WHAT IS WANTED)
@export var is_back_button: bool = false
var scene = null

func grab_focus_when_visibility_changed() -> void:
	call_deferred("grab_focus")

func _unhandled_input(event: InputEvent) -> void:
	if not is_back_button: return
	if event.is_action_pressed("ui_cancel"):  
		_on_pressed() 


func _ready() -> void:

	connect("visibility_changed", Callable(self, "grab_focus_when_visibility_changed"))
	call_deferred("grab_focus")
	
	if scene_file != "" and ResourceLoader.exists(scene_file):
		scene = load(scene_file)
	if has_signal("pressed"): self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if not scene: return

	if node_to_replace:
		var parent = node_to_replace.get_parent()
		node_to_replace.queue_free()
		parent.add_child(scene.instantiate())
		return
	
	get_tree().paused = false 
	Engine.time_scale = 1.0 ## Reset If changing the scene eg.(Pause Menu To Main Menu)
	get_tree().change_scene_to_packed(scene)
	
