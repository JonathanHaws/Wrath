# Make sure process mode for this node is 'always' so when game pauses it doesnt pause aswell
extends Node
func _ready() -> void: if not self.visible: toggle(false)

func toggle(paused: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if paused else Input.MOUSE_MODE_CAPTURED
	self.visible = paused
	Engine.time_scale = 0 if paused else 1
	get_tree().paused = paused

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		toggle(not self.visible) 
