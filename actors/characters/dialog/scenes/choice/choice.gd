extends AnimationPlayer
var info: Array = []
@export var disable_actions := ["controller_forward", "controller_left", "controller_right", "controller_back"]

func _on_choice_pressed(choice: Dictionary) -> void:
	if Controls: Controls.play_input_anim("choice_disabled")
	_capture_cursor()
	queue("exited")
	if "skip" in choice: 
		get_parent().goto(choice.skip)

func exit_area() -> void:
	queue("exited")

func spawn_next_dialog() -> void:
	get_parent()._spawn(true)

func _capture_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _release_cursor():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _exit_tree():
	if Controls: Controls.play_input_anim("choice_disabled")

func _ready():
	
	if Controls: Controls.play_input_anim("choice_enabled")
	
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
	

		
