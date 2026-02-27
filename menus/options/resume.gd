extends Button
@export var pause_toggler: Node

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu_back"):  # usually B / Esc
		## Controller B to exit skill tree but dont dash
		await get_tree().physics_frame 
		await get_tree().physics_frame
		
		_on_pressed()

func _on_pressed() -> void:
	if pause_toggler:
		pause_toggler.toggle(false)

func _ready() -> void:
	if pause_toggler: pressed.connect(_on_pressed)
