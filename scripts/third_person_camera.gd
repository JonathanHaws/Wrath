extends Camera3D
@export_group("Camera")
@export_range(-90.0, 90.0, 1.0, "Degrees") var pitch_min_deg: float = -80.0
@export_range(-90.0, 90.0, 1.0, "Degrees") var pitch_max_deg: float = 80.0
@export var SpringArm: SpringArm3D
@export var MOUSE_SENSITIVITY = 0.003
@export var LOCK_ON_SPEED = 7
@export var LOCK_ON_OFFSET: float = 4.0
@export var LOCK_ON_AREA: Area3D
@export var LOCK_ON_INDICATOR: Node
@export var ignore_mouse_when_visible := true
var lock_on_activated = false
var lock_on_target: Area3D
var lock_on_targets: Array[Area3D] = []

var mouse_delta = Vector2.ZERO

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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta += event.relative

func rotate_mesh_towards_camera_xz(delta: float, mesh: Node3D, input_vector: Vector2, turn_speed: float = 16) -> void:
	if input_vector.length() == 0: return
	var input_angle = atan2(-input_vector.x, -input_vector.y)
	mesh.global_rotation.y = lerp_angle(mesh.global_rotation.y, SpringArm.global_rotation.y + input_angle, turn_speed * delta)

func constrain_camera_angle() -> void:
	SpringArm.rotation_degrees.x = clamp(SpringArm.rotation_degrees.x, pitch_min_deg, pitch_max_deg)

func get_distance_from_center_of_screen(world_position: Vector3) -> float:
	var screen_pos = unproject_position(world_position)
	var screen_center = get_viewport().size * 0.5
	return screen_center.distance_to(screen_pos)

func _lock_on_process() -> void:
	if Input.is_action_just_pressed("lock_on"):
		if not lock_on_activated: # lock on to target closest to center of screen
			lock_on_targets.sort_custom(func(a, b): return get_distance_from_center_of_screen(a.global_position) < get_distance_from_center_of_screen(b.global_position))
			lock_on_target = lock_on_targets[0] if lock_on_targets.size() > 0 else null
			lock_on_activated = lock_on_target != null
		else:
			lock_on_activated = false
			lock_on_target = null

	if lock_on_activated and is_instance_valid(lock_on_target):
		LOCK_ON_INDICATOR.visible = true
		LOCK_ON_INDICATOR.position = unproject_position(lock_on_target.global_transform.origin)
	else:
		lock_on_activated = false
		LOCK_ON_INDICATOR.visible = false
		
func _lock_on_physics_process(_delta: float)-> void:
	# Camera rotation should be done in physics process to not clip through walls with spring arm as collison is calcuated in that step
	
	if not lock_on_activated: return
	if not is_instance_valid(lock_on_target): return
	
	var current_rotation = SpringArm.global_rotation
	SpringArm.look_at(lock_on_target.global_position - SpringArm.position, Vector3.UP)
	var new_rotation = SpringArm.global_rotation
	
	SpringArm.global_rotation.x = lerp_angle(current_rotation.x, new_rotation.x, LOCK_ON_SPEED * _delta)
	SpringArm.global_rotation.y = lerp_angle(current_rotation.y, new_rotation.y, LOCK_ON_SPEED * _delta)
	mouse_delta = Vector2.ZERO
	constrain_camera_angle()

func _ready() -> void:
	LOCK_ON_AREA.area_entered.connect(_on_lock_on_area_entered)
	LOCK_ON_AREA.area_exited.connect(_on_lock_on_area_exited)
	
func _process(_delta: float) -> void:
	_lock_on_process()
				
func _physics_process(delta: float) -> void:
	
	SpringArm.collision_mask = 0 if God.mode else 1
	
	if ignore_mouse_when_visible and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		mouse_delta = Vector2.ZERO
		return
	
	var look_left_right = Input.get_axis("look_left", "look_right")
	var look_up_down = Input.get_axis("look_down", "look_up")
	mouse_delta.x += look_left_right * MOUSE_SENSITIVITY * 3000
	mouse_delta.y -= look_up_down * MOUSE_SENSITIVITY * 3000
	
	_lock_on_physics_process(delta)
	
	if mouse_delta.length() > 0:
		SpringArm.global_rotation.y -= mouse_delta.x * MOUSE_SENSITIVITY
		SpringArm.global_rotation.x -= mouse_delta.y * MOUSE_SENSITIVITY
		mouse_delta = Vector2.ZERO
		constrain_camera_angle()
