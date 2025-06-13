extends Node
@export var DEBUG = false
@export var FLY_SPEED = 10.0
@export var PLAYER = CharacterBody3D

func _physics_process(delta: float) -> void:
	
	var keyboard_vector := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_forward", "keyboard_back")
	var controller_vector := Input.get_vector("controller_left", "controller_right", "controller_forward", "controller_back")
	var input_vector := keyboard_vector + controller_vector
	
	if DEBUG and PLAYER:
		PLAYER.velocity.x = input_vector.x * FLY_SPEED
		PLAYER.velocity.y = input_vector.y * FLY_SPEED
		PLAYER.velocity.z = 0.0
