extends AnimationPlayer
@export var info: String = ""
@export var label: Label
@export var reveal_animation_player: AnimationPlayer
@export var reveal_skipped_animation: String = "SKIPPED"

func _ready():
	label.text = info

func exit_area() -> void:
	queue("exited")

func spawn_next_dialog() -> void:
	get_parent()._spawn(true)
	
func _process(_delta):
	if Input.is_action_just_pressed("interact"): 
		if reveal_animation_player and reveal_animation_player.is_playing() and reveal_animation_player.has_animation(reveal_skipped_animation):
			reveal_animation_player.play(reveal_skipped_animation, 0)
		else:
			queue("exited")	# already done → end

					
