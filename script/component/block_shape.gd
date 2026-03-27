extends Area3D
@export var anim_player: AnimationPlayer
@export var block_anim: String = "BLOCK"
@export var block_multiplier: float = 0.2
var enabled_time: float = 0.0 ## Used by hurtshape to know how long blocking has been enabled

@export_group("Audio")
@export var audio_duck_nodes: Array[Node] = [] ## audio player nodes to quiet breifly when block animation is played
@export var duck_amount: float = -10.0 ## volume reduction in dB

func play_blocked_animation() -> void:
	if not anim_player: return
	if not anim_player.has_animation(block_anim): return
	if anim_player.is_playing(): return	
		
	#print('test')
	
	anim_player.play(block_anim)
	
	for node in audio_duck_nodes:
		node.volume_db += duck_amount
		await get_tree().create_timer(0.2).timeout
		node.volume_db -= duck_amount
		
func _process(delta: float) -> void:
	
	var collision_enabled: bool = false
	for shape in get_children():
		if shape is CollisionShape3D and not shape.disabled:
			collision_enabled = true
			break
	
	if collision_enabled: enabled_time += delta
	else: enabled_time = 0.0
	
	#print(enabled_time)
