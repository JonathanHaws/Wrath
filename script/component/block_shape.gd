extends Area3D
@export var block_multiplier: float = 0.2
@export var anim_player: AnimationPlayer
@export var block_anim: String = "BLOCK"
@export var enabled_time: float = 0.0 ## Used by hurtshape to know how long blocking has been enabled

func play_blocked_animation() -> void:
	if anim_player and anim_player.has_animation(block_anim):
		anim_player.play(block_anim)

func _process(delta: float) -> void:
	
	var collision_enabled: bool = false
	for shape in get_children():
		if shape is CollisionShape3D and not shape.disabled:
			collision_enabled = true
			break
	
	if collision_enabled: enabled_time += delta
	else: enabled_time = 0.0
	
	#print(enabled_time)
