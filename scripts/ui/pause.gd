
# Make sure process mode for this node is 'always' so when game pauses it doesnt pause aswell
extends CanvasLayer
func _on_resume_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.visible = false
	Engine.time_scale = 1
	get_tree().paused = false
func _on_pause_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
	self.visible = true;
	Engine.time_scale = 0
	get_tree().paused = true

func _ready() -> void:
	_on_resume_pressed()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if self.visible:
			_on_resume_pressed()	
		else :
			_on_pause_pressed()
