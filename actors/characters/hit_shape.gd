extends Area3D
@export var HEALTH = 500
@export var MAX_HEALTH = 500
@export var IMMUNE_GROUPS: Array[String] = []

@export_group("DAMAGE REACTION")
## For Body / Child Nodes which have to reposition themselves. Such as Needed positional synchronization between attacker / attacked on animations, Hurt Particles, etc.
@export var TELEPORT_NODES_TO_HIT: Array[Node3D] = [] 
@export var ANIMATION_PLAYERS: Array[AnimationPlayer] = []
@export var HURT_ANIM: String = "HURT"
@export var DEATH_ANIM: String = "DEATH"
@export var damage_numbers: PackedScene = preload("uid://dx5gfq7hao3tx")
func show_damage(damage_amount: int) -> void:
	if damage_numbers: #
		var number = damage_numbers.instantiate()
		number.get_node("Node2D/Label").text = str(int(damage_amount))
		get_tree().current_scene.add_child(number)
		number.position = get_viewport().get_camera_3d().unproject_position(self.global_position) - Vector2(0, 140.0)

func hit(area: Area3D, damage: int)-> void:
	
	for immune_group in IMMUNE_GROUPS: if area.is_in_group(immune_group): return
	
	HEALTH -= damage
	
	for node in TELEPORT_NODES_TO_HIT:
		node.global_transform.origin = area.global_transform.origin
		
	for anim_player in ANIMATION_PLAYERS:
		if HEALTH > 0 and anim_player.has_animation(HURT_ANIM):
			anim_player.call_deferred("play", HURT_ANIM)
		elif HEALTH <= 0 and anim_player.has_animation(DEATH_ANIM):
			anim_player.call_deferred("play", DEATH_ANIM)
