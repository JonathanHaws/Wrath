extends AnimationPlayer
var info: Array = []

func _captured_mouse() ->void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_choice_pressed(choice: Dictionary) -> void:
	queue("exited")
	get_parent().next_queued = true
	if "skip" in choice:
		get_parent().current_index += 1 + choice.skip

func _visible_mouse() ->void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

func _ready():
	$Options/Choice1.text = ""
	$Options/Choice2.text = ""
	if info.size() > 0:
		$Options/Choice1.text = info[0].text 
		$Options/Choice1.pressed.connect(func(): _on_choice_pressed(info[0]))
	if info.size() > 1:
		$Options/Choice2.text = info[1].text 	
		$Options/Choice2.pressed.connect(func(): _on_choice_pressed(info[1]))

func _process(_delta):
	if not get_parent().in_range: 
		queue("exited")
		return
