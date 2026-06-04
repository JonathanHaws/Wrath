extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(_delta: float) -> void:
	print($AnimationPlayer.current_animation)
