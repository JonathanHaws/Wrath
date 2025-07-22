extends Node
@export var CAMERA: Camera3D
@export var SpringArm: SpringArm3D
@export var LOCK_ON_SPEED = 7
@export var LOCK_ON_OFFSET: float = 4.0
@export var LOCK_ON_AREA: Area3D
var lock_on_activated = false
var lock_on_target: Area3D
var lock_on_targets: Array[Area3D] = []

func _on_lock_on_area_entered(area: Node) -> void:
	if area.name == "LockOn":
		lock_on_targets.append(area)
		if lock_on_targets.size() == 1:
			lock_on_target = area

func _on_lock_on_area_exited(area: Node) -> void:
	if area in lock_on_targets:
		lock_on_targets.erase(area)
		if area == lock_on_target:
			lock_on_target = lock_on_targets[0] if lock_on_targets.size() > 0 else null

func get_distance_from_center_of_screen(world_position: Vector3) -> float:
	var screen_pos = CAMERA.unproject_position(world_position)
	var screen_center = get_viewport().size * 0.5
	return screen_center.distance_to(screen_pos)

func _ready() -> void:
	LOCK_ON_AREA.area_entered.connect(_on_lock_on_area_entered)
	LOCK_ON_AREA.area_exited.connect(_on_lock_on_area_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("lock_on"):
		if not lock_on_activated: # lock on to target closest to center of screen
			
			lock_on_targets.sort_custom(func(a, b):
				if not CAMERA.has_method("get_distance_from_center_of_screen"): # these 2 lines had to add from weird glitch if lock on is spammed
					return false
				var dist_a = CAMERA.get_distance_from_center_of_screen(a.global_position)
				var dist_b = CAMERA.get_distance_from_center_of_screen(b.global_position)
				return dist_a < dist_b
			)
			
			lock_on_target = lock_on_targets[0] if lock_on_targets.size() > 0 else null
			lock_on_activated = lock_on_target != null
		else:
			lock_on_activated = false
			lock_on_target = null

	if lock_on_activated and is_instance_valid(lock_on_target):
		self.visible = true
		self.position = CAMERA.unproject_position(lock_on_target.global_transform.origin)
	else:
		lock_on_activated = false
		self.visible = false
		
func _physics_process(_delta: float) -> void:
	
	CAMERA.ENABLED = not lock_on_activated
	
	if not lock_on_activated: return
	if not is_instance_valid(lock_on_target): return

	var current_rotation = SpringArm.global_rotation
	SpringArm.look_at(lock_on_target.global_position - SpringArm.position, Vector3.UP)
	var new_rotation = SpringArm.global_rotation
	
	
	SpringArm.global_rotation.x = lerp_angle(current_rotation.x, new_rotation.x, LOCK_ON_SPEED * _delta)
	SpringArm.global_rotation.y = lerp_angle(current_rotation.y, new_rotation.y, LOCK_ON_SPEED * _delta)
		
