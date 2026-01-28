extends Area3D
@export var hitshape: Area3D  
@export var block_multiplier: float = 0.2
@export var active: bool = false
@export var anim_player: AnimationPlayer
@export var block_anim: String = "BLOCK"

func hit(area: Area3D, damage: int) -> bool:
	
	if anim_player and anim_player.has_animation(block_anim):
		anim_player.play(block_anim)
	
	if hitshape and hitshape.has_method("hit"):
		return hitshape.hit(area, int(damage * block_multiplier), false)
	return false
