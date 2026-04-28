extends RayCast3D
@export var climb_speed: float = 300.0
@export var stick_force: float = 3.0
@export var climbable_group: String = "climbable"
@export var player_group: String = "player_body"
@export var player_mesh_group: String = "player_mesh"
@export var player_anim_group: String = "player_anim"

@onready var anim: AnimationPlayer = get_tree().get_nodes_in_group(player_anim_group)[0]
@onready var player: Node = get_tree().get_nodes_in_group(player_group)[0]
@onready var player_mesh: Node = get_tree().get_nodes_in_group(player_mesh_group)[0]
var climbing: bool = false
var was_climbing: bool = false
var climb_surface: Node = null
var jumped_off: bool = false

var climbing_point: Vector3
#func get_next_climbing_point(delta: float) -> void:
	#pass

#var mesh_data := MeshDataTool.new()

# Potential fixes
# Make it so that if not moving no jiggling. stores a point

# get collison point. raycast from there to always stay wrapped. And turn of collison on player and gravity
# and interpolate

func _physics_process(delta: float) -> void:
	force_raycast_update()
	
	if player.is_on_floor() and not climbing:
		jumped_off = false
	
	if not jumped_off \
	and is_colliding() \
	and get_collider() \
	and get_collider().is_in_group(climbable_group):
		climbing_point = get_collision_point()
		climbing = true
	else:
		climbing = false
		
	#if is_colliding() \
	#and not get_collider().is_in_group(climbable_group):
		#print(get_collider())
				
	#if climbing and 

	if climbing and not was_climbing and not jumped_off:
		anim.play("CLIMBING_ENTER")
	
	if not climbing and was_climbing:
		was_climbing = false
		#print('disconnecintg')
		anim.play("CLIMBING_EXIT")
		#player.global_transform.basis = Basis.IDENTITY
		
		var flat_direction: Vector3 = -player.global_transform.basis.z
		flat_direction.y = 0
		player.look_at(player.global_position + flat_direction.normalized(), Vector3.UP)
		#
		#player_mesh.transform = Transform3D.IDENTITY
	
	#if anim not in ["CLIMBING_ENTER", "CLIMBING"]: return
	if not climbing: return
	was_climbing = climbing
	
	player.velocity = -player.velocity
	var normal := get_collision_normal()
	var target_basis := Basis.looking_at(-normal, Vector3.UP)
	player.global_transform.basis = player.global_transform.basis.slerp(target_basis, 0.2)
	player_mesh.transform = Transform3D.IDENTITY
	var right: Vector3 = player.global_transform.basis.x
	var up: Vector3 = player.global_transform.basis.y
	var anim_scale := 0.0
	
	if Input.is_action_just_pressed("jump"):
		climbing = false
		jumped_off = true
	
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
	
	if anim and not anim.current_animation in ["CLIMBING_ENTER","CLIMBING_EXIT"]:
		if anim_scale == 0: anim.stop(true)
		else: anim.play("CLIMBING")
	
	player.move_and_slide()
	player.velocity = Vector3.ZERO
