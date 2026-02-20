extends AnimationPlayer
@export var dialog: Node ## Auto assigned from parent spawner
@export var info: String = "" ## Auto assigned from parent spawner
@export var label: Label
@export var reveal_animation_player: AnimationPlayer
@export var reveal_skipped_animation: String = "SKIPPED"

func _ready():
	label.text = info

func exit_area() -> void:
	queue("exited")

func spawn_next_dialog() -> void:
	if dialog.in_range:
		dialog.goto(dialog.index + 1)
		dialog.spawn()
	
func _process(_delta):
	if Input.is_action_just_pressed("interact"): 
		if reveal_animation_player and reveal_animation_player.is_playing() and reveal_animation_player.has_animation(reveal_skipped_animation):
			reveal_animation_player.play(reveal_skipped_animation, 0)
		else:
			queue("exited")	# already done → end
	
