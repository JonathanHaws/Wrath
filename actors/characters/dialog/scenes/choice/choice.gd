extends AnimationPlayer
var info: Array = []
@export var disable_actions := ["controller_forward", "controller_left", "controller_right", "controller_back"]

func _on_choice_pressed(choice: Dictionary) -> void:
	DisableInput.toggle_action(disable_actions, true)
	Controls.hide_mouse()
	queue("exited")
	if "skip" in choice: get_parent().skip_to(choice.skip)
	tree_exited.connect(get_parent()._spawn_next_dialog)

func exit_area(): 
	if not current_animation == "exited":
		queue("exited")

func _hide_cursor():
	Controls.hide_mouse()

func _show_cursor():
	Controls.show_mouse()

func _exit_tree():
	DisableInput.toggle_action(disable_actions, true)

func _ready():
	
	DisableInput.toggle_action(disable_actions, false)
	
	$Options/Choice1.text = ""
	$Options/Choice2.text = ""
	if info.size() > 0:
		$Options/Choice1.text = info[0].text 
		$Options/Choice1.pressed.connect(func(): _on_choice_pressed(info[0]))
	if info.size() > 1:
		$Options/Choice2.text = info[1].text 	
		$Options/Choice2.pressed.connect(func(): _on_choice_pressed(info[1]))

func _process(_delta):
	
	if not current_animation == "exited": _show_cursor()
	

		
