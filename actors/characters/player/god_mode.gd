extends Node
@export var FLY_SPEED: float = 0.4
@export var ASCEND_SPEED: float = 50.0
@export var DESCEND_SPEED: float = 50.0
@export var SPRINT_MULTIPLIER = 2.1
@export var PLAYER: Node 
@export var MESH: Node 
@export var CAMERA: Node 
@export var BODY_SHAPE: Node 
@export var HITBOX_SHAPE: Node 
@export var DAMAGE_SHAPE: Node
@export var ANIMATION_PLAYER: AnimationPlayer
@export var GOD_MODE_ANIMATION: StringName = &"GOD"
var mode := false
var last_position: Vector3

func _ready():
	
	if not OS.is_debug_build():
		queue_free()

func _physics_process(_delta):
	if Input.is_action_just_pressed("god_mode"):
		mode = !mode
		#if DAMAGE_SHAPE: DAMAGE_SHAPE.disabled = !DAMAGE_SHAPE.disabled
		if mode and ANIMATION_PLAYER and GOD_MODE_ANIMATION != "":
			ANIMATION_PLAYER.play(GOD_MODE_ANIMATION)
		
	if mode: 
		if Input.is_action_just_pressed("get_wisp"):
			Save.data["wisp"] = Save.data.get("wisp", 0) + 50
		
		PLAYER.global_transform.origin = last_position
			
		if BODY_SHAPE: BODY_SHAPE.disabled = true
		if HITBOX_SHAPE: HITBOX_SHAPE.disabled = true
		if DAMAGE_SHAPE: DAMAGE_SHAPE.disabled = false
		
		var keyboard_vector := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_forward", "keyboard_back")
		var controller_vector := Input.get_vector("controller_left", "controller_right", "controller_forward", "controller_back")
		var input_vector := keyboard_vector + controller_vector
	
		if Input.is_action_pressed("jump"):
			PLAYER.position.y += ASCEND_SPEED * _delta
		if Input.is_action_pressed("descend"):
			PLAYER.position.y -= DESCEND_SPEED * _delta
	
		PLAYER.velocity = Vector3.ZERO
	
		if input_vector.length() > 0:
			if MESH: 
				var mesh_direction = -MESH.global_transform.basis.z
				var speed_factor = SPRINT_MULTIPLIER
				if Input.is_action_pressed("walk") or controller_vector.length() < 0.75:
					speed_factor = 1.0

				PLAYER.position.x += mesh_direction.x * FLY_SPEED * speed_factor
				PLAYER.position.z += mesh_direction.z * FLY_SPEED * speed_factor
			
			var direction = -CAMERA.global_transform.basis.z.normalized() # move towards camera
			PLAYER.global_transform.origin.y += direction.y * FLY_SPEED * _delta	
			
	else:
		if BODY_SHAPE: BODY_SHAPE.disabled = false
		if HITBOX_SHAPE: HITBOX_SHAPE.disabled = false
		if DAMAGE_SHAPE: DAMAGE_SHAPE.disabled = true
		
	if CAMERA: CAMERA.SpringArm.collision_mask = 0 if mode else 1

	last_position = PLAYER.global_transform.origin  # save position
