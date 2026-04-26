extends RayCast3D
@export var climb_speed: float = 200.0
@export var stick_force: float = 1.0
@export var climbable_group: String = "climbable"
@export var player_group: String = "player_body"
@export var player_mesh_group: String = "player_mesh"
@export var player_anim_group: String = "player_anim"

@onready var anim: AnimationPlayer = get_tree().get_nodes_in_group(player_anim_group)[0]
@onready var player: Node = get_tree().get_nodes_in_group(player_group)[0]
@onready var player_mesh: Node = get_tree().get_nodes_in_group(player_mesh_group)[0]
var climbing: bool = false
var was_climbing: bool = false
var climbing_position: Vector3
var climb_surface: Node = null

func _physics_process(delta: float) -> void:
	force_raycast_update()
	
	was_climbing = climbing
	climbing = is_colliding() and get_collider() and get_collider().is_in_group(climbable_group)
				
	#if climbing and 

	if climbing and not was_climbing:
		climbing_position = player.global_position
		anim.play("LADDER_ENTER")
	
	if not climbing and was_climbing:
		anim.play("LADDER_EXIT")	
	
	if not climbing: return
	player.velocity = -player.velocity
	
	var normal := get_collision_normal()
	var target_basis := Basis().looking_at(-normal, Vector3.UP)
	player.global_transform.basis = player.global_transform.basis.slerp(target_basis, 0.2)
	player_mesh.transform = Transform3D.IDENTITY
	var right: Vector3 = player.global_transform.basis.x
	var up: Vector3 = player.global_transform.basis.y
	var forward: Vector3 = -player.global_transform.basis.z
	var anim_scale := 0.0
	
	if Input.is_action_pressed("keyboard_forward"):
		player.velocity += up * climb_speed * delta
		player.velocity += normal * -stick_force
		anim_scale = 1.0
	if Input.is_action_pressed("keyboard_back"):
		player.velocity -= up * climb_speed * delta
		player.velocity += normal * -stick_force
		anim_scale = 1
	if Input.is_action_pressed("keyboard_right"):
		player.velocity += right * climb_speed * delta
		player.velocity += normal * -stick_force
		anim_scale = 1.0
	if Input.is_action_pressed("keyboard_left"):
		player.velocity -= right * climb_speed * delta
		player.velocity += normal * -stick_force
		anim_scale = 1.0
	
	if anim and not anim.current_animation in ["LADDER_ENTER","LADDER_EXIT"]:
		if anim_scale == 0: anim.stop(true)
		else: anim.play("LADDER")
	
	player.move_and_slide()
	player.velocity = Vector3.ZERO
	

	
