extends Node3D
@export var speed = 15.0
@export var destroy_area: Area3D
@export var body_exclude_groups: Array[String] = []
@export var area_exclude_groups: Array[String] = []
@export var destroy_on_every_body_entered: bool = true
@export var destroy_on_every_area_entered: bool = false

@export var gravity: float = 0.0  
var velocity: Vector3

@export var home_in_ready: bool = false
@export var homing: bool = false
@export var homing_group: String = "player_body"
@export var homing_speed: float = 2.0  
@export var homing_offset: Vector3 = Vector3(0, .5, 0)

func _ready():
	
	velocity = -global_transform.basis.z * speed  # forward
	
	if destroy_area:
		destroy_area.body_entered.connect(_on_body_entered)
		destroy_area.area_entered.connect(_on_area_entered)
	if home_in_ready:
		await get_tree().process_frame
		var targets = get_tree().get_nodes_in_group(homing_group)
		if targets.size() > 0:
			look_at(targets[0].global_position + homing_offset, Vector3.UP)

func _process(delta):
	
	if homing:
		var targets = get_tree().get_nodes_in_group(homing_group)
		if targets.size() > 0:
			var current_rot = global_transform.basis.orthonormalized()
			look_at(targets[0].global_position + homing_offset, Vector3.UP)
			var target_rot = global_transform.basis.orthonormalized()
			global_transform.basis = current_rot.slerp(target_rot, homing_speed * delta)
			
	translate(velocity * delta)

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
