extends Label
@export var action_name: String = "interact"
@export var display_text: String = "Interact"

func _ready():
	text = display_text + ": " + Controls.get_string_from_action(action_name)
