extends Node
var mode := false

func _process(_delta):
	if Input.is_action_just_pressed("god_mode"):
		mode = !mode
