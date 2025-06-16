extends CharacterBody3D
@export var HURT_PARTICLE_SCENE: PackedScene
@export var DAMAGE_NUMBER: PackedScene
@export var health = 250
#var health:
	#get: return HEALTH.value
	#set(value): HEALTH.value = clamp(value, HEALTH.min_value, HEALTH.max_value)

func hurt(_damage: float = 0, _group: String = "", _position: Vector3 = Vector3.ZERO) -> void:
	WorldUI.show_symbol(global_position, DAMAGE_NUMBER, 140.0, "Node2D/Label", _damage)
	SlowMotion.impact(.04)
	Shake.tremor(2)
	if $Audio: $Audio.play_2d_sound(["hit_1", "hit_2", "hit_3"], .8)
	Particles.spawn(HURT_PARTICLE_SCENE, _position)
	if health <= 0:
		queue_free()	
