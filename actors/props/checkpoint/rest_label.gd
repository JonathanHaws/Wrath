extends Label
@export var action_name: String = "interact"
@export var display_text: String = "Interact"

func _ready():
	text = display_text + ": " + Controls.get_action_bindings(action_name)
