extends Node
@export var save_key: String
@export var node_to_queue_free: Node
@export var anim_player: AnimationPlayer
@export var anim_name_to_play: String
@export var enable_collision_shape: CollisionShape3D

func _check_and_apply() -> void:
	if not Save.data.has(save_key): return
	
	if enable_collision_shape:
		enable_collision_shape.disabled = false
	
	if anim_player:
		anim_player.play(anim_name_to_play)
	
	if node_to_queue_free:
		node_to_queue_free.queue_free()

func _ready() -> void:
	_check_and_apply()
	
func _physics_process(_delta):
	_check_and_apply()
