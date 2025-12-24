extends Area3D
@export var HEALTH :float = 500.0
@export var MAX_HEALTH	:float = 500.0
@export var IMMUNE_GROUPS: Array[String] = []
@export var INVINCIBILITY_COOLDOWN: float = 0.0 ## After object gets hit how long they are invincible
@export var DISABLED: bool = false
var last_hurt_shape: Area3D = null # most recent hurt_shape to damage this shape
var invincibility_timer: Timer

@export_group("DAMAGE REACTION") ## For Body / Child Nodes which have to reposition themselves. Such as Needed positional synchronization between attacker / attacked on animations, Hurt Particles, etc.
@export var TELEPORT_NODES_TO_HIT: Array[Node3D] = [] 
@export var HURT_ANIMATION_PLAYER: AnimationPlayer
@export var DEATH_ANIMATION_PLAYER: AnimationPlayer
@export var HEAL_ANIMATION_PLAYER: AnimationPlayer
@export var HURT_ANIM: String = "HURT"
@export var DEATH_ANIM: String = "DEATH"
@export var HEAL_ANIM: String = "HEAL"
signal DIED
signal HURT
signal HEAL

@export_group("WAVE HEALTH BAR") ## For bosses or encounters that spawn waves of enemies
@export var USE_WAVE_HEALTH_BAR: bool = false ## optional group for wave health
@export var WAVE_HITSHAPE_GROUP: String = "enemy_hitshape" ## optional group for wave health
@export var WAVE_DAMAGE :float = 300.0 ## The amount to decrease health when enemies die

@export var DAMAGE_NUMBERS: PackedScene
func show_damage(damage_amount: int) -> void:
	var number = DAMAGE_NUMBERS.instantiate()
	number.get_node("Node2D/Label").text = str(int(damage_amount))
	get_tree().current_scene.add_child(number)
	number.position = get_viewport().get_camera_3d().unproject_position(self.global_position) - Vector2(0, 140.0)

func hit(area: Area3D = null, damage: int = 0)-> void:
	if DISABLED: return
	if invincibility_timer: if invincibility_timer.is_stopped() == false: return  
	if area: for immune_group in IMMUNE_GROUPS: if area.is_in_group(immune_group): return
	HEALTH -= damage
	last_hurt_shape = area 
	if invincibility_timer: invincibility_timer.start()
	
	if DAMAGE_NUMBERS: show_damage(damage)
	
	if area:
		for node in TELEPORT_NODES_TO_HIT:
			if node is Node3D: node.global_transform.origin = area.global_transform.origin
		
	if HEALTH > 0 and damage > 0: # HURT
		if HURT_ANIMATION_PLAYER and HURT_ANIMATION_PLAYER.has_animation(HURT_ANIM):
			HURT.emit()
			HURT_ANIMATION_PLAYER.play(HURT_ANIM)
	if HEALTH <= 0: # DEATH
		if DEATH_ANIMATION_PLAYER and DEATH_ANIMATION_PLAYER.has_animation(DEATH_ANIM):
			DIED.emit()
			DISABLED = true
			DEATH_ANIMATION_PLAYER.play(DEATH_ANIM)	
	if damage < 0: # HEAL
		if HEAL_ANIMATION_PLAYER and HEAL_ANIMATION_PLAYER.has_animation(HEAL_ANIM):
			HEAL.emit()
			HEAL_ANIMATION_PLAYER.play(HEAL_ANIM)
			
func _ready():
	if INVINCIBILITY_COOLDOWN > 0:
		invincibility_timer = Timer.new()
		invincibility_timer.one_shot = true
		invincibility_timer.wait_time = INVINCIBILITY_COOLDOWN
		add_child(invincibility_timer)
		
func _process(_delta):
	
	if USE_WAVE_HEALTH_BAR:
		var callback := Callable(self, "hit").bind(null, WAVE_DAMAGE)
		for e in get_tree().get_nodes_in_group(WAVE_HITSHAPE_GROUP):
			if e != self and not e.DIED.is_connected(callback):
				e.DIED.connect(callback)
	
		
#func _process(delta: float) -> void:
	#print(HEALTH)
