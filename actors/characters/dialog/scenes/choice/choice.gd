extends AnimationPlayer
@export var dialog: Node ## Auto assigned from parent spawner
var info: Array = [] ## Auto assigned from parent spawner
var choice_chosen: int = -1
@export var disable_actions := ["controller_forward", "controller_left", "controller_right", "controller_back"]
## ADD option to save choices as already explored so omit them... Or to point out how odd it is your asking the same question again

func _on_choice_pressed(choice: Dictionary) -> void:
	choice_chosen = info.find(choice)
	if info[choice_chosen].has("end"): 
		dialog.end()
	
	if Controls: Controls.play_input_anim("choice_disabled")
	_capture_cursor()
	queue("exited")
	if dialog.in_range:
		if "skip" in choice: 
			dialog.goto(choice.skip)
		else:
			dialog.goto(dialog.index + 1)

func exit_area() -> void:
	queue("exited")

func spawn_next_dialog() -> void:
	if dialog.in_range and not info[choice_chosen].has("end"):
		dialog.spawn()

func _capture_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _release_cursor():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _exit_tree():
	if Controls: Controls.play_input_anim("choice_disabled")

func _ready():
	
	if Controls: Controls.play_input_anim("choice_enabled")
	
	$Options/Choice1.call_deferred("grab_focus")
	$Options/Choice2.call_deferred("grab_focus")
	
	$Options/Choice1.text = ""
	$Options/Choice2.text = ""
	if info.size() > 0:
		$Options/Choice1.text = info[0].text 
		$Options/Choice1.pressed.connect(func(): _on_choice_pressed(info[0]))
	if info.size() > 1:
		$Options/Choice2.text = info[1].text 	
		$Options/Choice2.pressed.connect(func(): _on_choice_pressed(info[1]))

func _process(_delta):
	
	if not current_animation == "exited": _release_cursor()
	

		
