extends Area3D
@export var hitshape: Area3D  
@export var block_multiplier: float = 0.2
@export var active: bool = false
@export var anim_player: AnimationPlayer
@export var block_anim: String = "BLOCK"
var enabled_time: float = 0.0

func hit(area: Area3D, damage: int) -> bool:
	
	if anim_player and anim_player.has_animation(block_anim):
		anim_player.play(block_anim)
	
	if "blocked" in area: area.blocked(enabled_time)
	
	if hitshape and hitshape.has_method("hit"):
		return hitshape.hit(area, int(damage * block_multiplier), false)
	return false
	
func _physics_process(delta: float) -> void:
	var collision_enabled := false
	for shape in get_children():
		if shape is CollisionShape3D and not shape.disabled:
			collision_enabled = true
			break
	
	if collision_enabled: enabled_time += delta
	else: enabled_time = 0.0
