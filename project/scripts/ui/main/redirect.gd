extends Button

@export var target_to_hide: NodePath = "../" 
@export var target_to_show: NodePath = "../../Main"

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if has_node(target_to_hide): get_node(target_to_hide).visible = false
	if has_node(target_to_show): get_node(target_to_show).visible = true
