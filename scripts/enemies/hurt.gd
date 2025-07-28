extends Node
@export var anim: AnimationPlayer = null
@export var body: Node

func hurt(_damage: float = 0, _group: String = "", _position: Vector3 = Vector3.ZERO) -> void:
	WorldUI.show_symbol(_position, 140.0, "Node2D/Label", _damage)
	SlowMotion.impact(.04)
	Shake.tremor(2)
	#Particles.spawn(HURT_PARTICLE_SCENE, _position)

	if anim and anim.has_animation("hurt"):
		anim.play("hurt")
