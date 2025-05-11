extends AnimationPlayer
@export var area: Area3D
@export var player_group: String = "player"
@export var range: AnimationPlayer
@export var start_dialogue: StringName = "1"
var in_range = false

func _on_body_entered(body):
	if not body.is_in_group(player_group): return
	if range: range.queue("entered") 
	in_range = true
	play()

func _on_body_exited(body):
	if not body.is_in_group(player_group): return
	if range: range.queue("exited") 
	in_range = false
	var progress = get_current_animation_position()
	if (progress == 0 or progress == 1) : return
	play()

func _on_animation_changed(new: String, old: String):
	if not in_range: 
		play(start_dialogue)
		pause()

func _on_animation_finished(anim_name: String):
	play(start_dialogue)
	pause()

func freeze()->void:
	if in_range:
		pause()

func _ready():
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)	
	animation_changed.connect(_on_animation_changed)
	animation_finished.connect(_on_animation_finished)
	play(start_dialogue)
	pause()

func _process(_delta):
	if not in_range: return
	if Input.is_action_just_pressed("interact"): 
		play()
	
