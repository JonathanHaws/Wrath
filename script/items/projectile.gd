extends Node3D
@export_group("Trajectory")
@export var root: Node3D = self # specify root for movement/collision
@export var speed = 15.0
@export var gravity: float = 0.0  
@export var random_velocity_x: float = 0.0
@export var random_velocity_y: float = 0.0
var velocity: Vector3
var start_position: Vector3
var initial_velocity: Vector3
var age: float = 0.0

@export_subgroup("Homing")
@export var home_in_ready: bool = false
@export var homing: bool = false
@export var homing_group: String = "player_body"
@export var homing_speed: float = 2.0  
@export var homing_offset: Vector3 = Vector3(0, .5, 0)

@export_group("Collision")
@export var exclude_groups: Array[String] = [] 
@export var collision_animation_player: AnimationPlayer
@export var collision_animation_name: String = ""
@export var hurt_box: Node ## destroy when hurtboxes hit something
@export var collision_point: Node3D ## Node that will teleport to the point of collision. (Useful Chain Reaction Spawning)

func get_velocity_from_orientation() -> Vector3:
	var projectile_velocity: Vector3 = -global_transform.basis.z.normalized() * speed
	projectile_velocity += Vector3(
		randf_range(-random_velocity_x, random_velocity_x),
		randf_range(-random_velocity_y, random_velocity_y), 0)
	return projectile_velocity

func raycast(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to)
	for group in exclude_groups:
		for node in get_tree().get_nodes_in_group(group):
			if node is CollisionObject3D:
				query.exclude.append(node.get_rid())
	return get_world_3d().direct_space_state.intersect_ray(query)

func point_towards(node: Node3D, direction: Vector3) -> void:
	if direction.length_squared() <= 0.0: return
	var up := Vector3.UP
	if abs(direction.normalized().dot(up)) > 0.999: up = Vector3.RIGHT
	node.look_at(node.global_position + direction, up)

func get_position_from_age(t: float) -> Vector3:
	return (start_position
		+ initial_velocity * t
		+ Vector3.DOWN * gravity * t * t * 0.5
	)

func get_age_at_y_position(y: float) -> float:
	var a := -0.5 * gravity
	var b := initial_velocity.y
	var c := start_position.y - y

	var discriminant := b * b - 4.0 * a * c
	if discriminant < 0.0:
		return -1.0

	return (-b - sqrt(discriminant)) / (2.0 * a)

func play_collision_animation():
	if collision_animation_player and collision_animation_name != "":
		if collision_animation_player.current_animation != collision_animation_name:
			collision_animation_player.play(collision_animation_name, 0)
			collision_animation_player.advance(0)

func _on_hurt() -> void:
	#print("hurt")
	play_collision_animation()

func _ready():
	
	await get_tree().physics_frame
	
	if home_in_ready and get_tree().get_nodes_in_group(homing_group):
		var target = get_tree().get_nodes_in_group(homing_group)[0]
		look_at(target.global_position + homing_offset, Vector3.UP)
	
	if hurt_box and hurt_box.has_signal("collided_with_hitshape"):
		hurt_box.connect("collided_with_hitshape", Callable(self, "play_collision_animation"))
	
	start_position = root.global_position
	velocity = get_velocity_from_orientation()
	initial_velocity = get_velocity_from_orientation()
	
	#print(velocity)
	
func _physics_process(delta: float) -> void:

	age += delta
	var current_position = get_position_from_age(age)
	var next_position = get_position_from_age(age + delta)
	root.global_position = current_position
	
	point_towards(self, next_position - current_position)
	
	var hit: Dictionary = raycast(current_position, next_position)
	if not hit.is_empty():
		if collision_point:
			collision_point.global_position = hit.position
			point_towards(collision_point, hit.normal)

		play_collision_animation()
