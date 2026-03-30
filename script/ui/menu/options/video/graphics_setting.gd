extends Control
@export var setting_name: String = ""
@export var toggle_button: CheckButton
@export var slider: HSlider
@export var display_label: Label
@export var reset_button: Button

func _ready() -> void:

	# just convient auto assigment 
	if not toggle_button: toggle_button = get_node_or_null("CheckButton")
	if not slider: slider = get_node_or_null("HSlider")
	if not display_label: display_label = get_node_or_null("Label")
	if not reset_button: reset_button = get_node_or_null("Button")	# auto

	Config.connect_graphics_control(
		setting_name,
		toggle_button,
		slider,
		display_label,
		reset_button
	)
