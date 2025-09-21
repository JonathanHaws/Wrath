extends Area3D
@export var HEALTH = 500
@export var MAX_HEALTH = 500
@export var IMMUNE_GROUPS: Array[String] = []
@export var INVINCIBILITY_COOLDOWN: float = 0.0 ## After object gets hit how long they are invincible
var invincibility_timer: Timer

@export_group("DAMAGE REACTION")
## For Body / Child Nodes which have to reposition themselves. Such as Needed positional synchronization between attacker / attacked on animations, Hurt Particles, etc.
@export var TELEPORT_NODES_TO_HIT: Array[Node3D] = [] 
@export var HURT_ANIMATION_PLAYER: AnimationPlayer
@export var DEATH_ANIMATION_PLAYER: AnimationPlayer
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
	
	if invincibility_timer: if invincibility_timer.is_stopped() == false: return  
	for immune_group in IMMUNE_GROUPS: if area.is_in_group(immune_group): return
	HEALTH -= damage
	if invincibility_timer: invincibility_timer.start()
	
	for node in TELEPORT_NODES_TO_HIT:
		node.global_transform.origin = area.global_transform.origin
		
	if HEALTH > 0 and HURT_ANIMATION_PLAYER and HURT_ANIMATION_PLAYER.has_animation(HURT_ANIM):
		HURT_ANIMATION_PLAYER.play(HURT_ANIM)
	elif HEALTH <= 0 and DEATH_ANIMATION_PLAYER and DEATH_ANIMATION_PLAYER.has_animation(DEATH_ANIM):
		DEATH_ANIMATION_PLAYER.play(DEATH_ANIM)
			
func _ready():
	if INVINCIBILITY_COOLDOWN > 0:
		invincibility_timer = Timer.new()
		invincibility_timer.one_shot = true
		invincibility_timer.wait_time = INVINCIBILITY_COOLDOWN
		add_child(invincibility_timer)
		
#func _process(delta: float) -> void:
	#print(HEALTH)
