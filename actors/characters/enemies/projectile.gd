extends Node3D
@export var speed = 15.0
@export var gravity: float = 0.0  
@export var random_velocity_x: float = 0.0
@export var random_velocity_y: float = 0.0
@export var ray: RayCast3D
@export var exclude_groups: Array[String] = [] 
@export var collision_point: Node3D
@export var collision_animation_player: AnimationPlayer
@export var collision_animation_name: String = ""

@export var homing: bool = false
@export var homing_group: String = "player_body"
@export var homing_speed: float = 2.0  
@export var homing_offset: Vector3 = Vector3(0, .5, 0)

var velocity: Vector3

func _ready():
	await get_tree().process_frame
	velocity = -(global_transform.basis.z.normalized()) * speed		
	velocity +=  Vector3(randf_range(-random_velocity_x, random_velocity_x), randf_range(-random_velocity_y, random_velocity_y), 0)

func _physics_process(delta: float) -> void:
	if homing:pass #add the velocity being changed
	
	if gravity != 0.0:
		velocity.y -= gravity * delta

	if velocity.length() > 0.0:
		var up = Vector3.UP
		if abs(velocity.normalized().dot(up)) > 0.999:
			up = Vector3.RIGHT  # pick a perpendicular up
		look_at(global_position + velocity, up)
	
	ray.target_position = ray.to_local(global_position + velocity * delta)
	ray.force_raycast_update()
	if ray.is_colliding():
		var collider = ray.get_collider()
		var skip = false
		for group in exclude_groups:
			if collider.is_in_group(group):
				skip = true
				break

		if not skip:
			if collision_point:
				collision_point.global_position = ray.get_collision_point()
				
				var up = Vector3.UP
				if abs(ray.get_collision_normal().dot(Vector3.UP)) > 0.999:
					up = Vector3(0, 0, 1)
				collision_point.look_at(collision_point.global_position + ray.get_collision_normal(), up)

			if collision_animation_player and collision_animation_name != "":
				collision_animation_player.play(collision_animation_name)
				collision_animation_player.advance(0)  
	
	global_position += velocity * delta
