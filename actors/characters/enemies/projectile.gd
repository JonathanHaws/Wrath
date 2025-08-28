extends Node3D
@export var speed = 15.0
@export var destroy_area: Area3D
@export var body_exclude_groups: Array[String] = []
@export var area_exclude_groups: Array[String] = []
@export var destroy_on_every_body_entered: bool = true
@export var destroy_on_every_area_entered: bool = false

@export var gravity: float = 0.0  
var velocity: Vector3

@export var INPUT_READ_VELOCITY_MULTIPLIER: float = 0.0 ## Use targets body velocity to predict movement (Fire shot in front of player)

@export var home_in_ready: bool = false ## Perfectly orient to target in ready
@export var homing: bool = false
@export var homing_group: String = "player_body"
@export var homing_speed: float = 2.0  
@export var homing_offset: Vector3 = Vector3(0, .5, 0)

func _ready():
	await get_tree().process_frame
	velocity = -(global_transform.basis.z.normalized()) * speed
	
	if destroy_area:
		destroy_area.body_entered.connect(_on_body_entered)
		destroy_area.area_entered.connect(_on_area_entered)
	
	if home_in_ready:
		var targets = get_tree().get_nodes_in_group(homing_group)
		if targets.size() > 0:
			var target = targets[0].global_position + homing_offset
			var to_target = target - global_position	
			
			if "velocity" in targets[0]: # add predictive firing (firing in front of player)
				to_target += targets[0].velocity * INPUT_READ_VELOCITY_MULTIPLIER
			
			var distance = to_target.length()
			if not distance > 0.001: return
			var time = distance / speed

			if gravity > 0: # arc
				velocity = to_target / time
				velocity.y += 0.5 * gravity * time
			else: # straight
				velocity = to_target / time	

func _process(delta):

	if homing:	
		pass
		#add the velocity being changed
	
	if gravity != 0.0:
		velocity.y -= gravity * delta

	if velocity.length() > 0.0:
		look_at(global_position + velocity, Vector3.UP)
		
	global_position += velocity * delta

func _on_body_entered(body: Node) -> void:
	
	if destroy_on_every_body_entered:
		for group in body_exclude_groups:
			if body.is_in_group(group): return
	else: 
		for group in body_exclude_groups:
			if not body.is_in_group(group): return
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	if destroy_on_every_area_entered:
		for group in area_exclude_groups:
			if area.is_in_group(group): return
	else:
		for group in area_exclude_groups:
			if not area.is_in_group(group): return
	queue_free()
