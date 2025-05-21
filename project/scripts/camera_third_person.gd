extends Camera3D
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
var mouse_delta = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta += event.relative

func rotate_mesh_towards_camera_xz(delta: float, mesh: Node3D, input_vector: Vector2, turn_speed: float = 16) -> void:
	if input_vector.length() == 0: return
	var input_angle = atan2(-input_vector.x, -input_vector.y)
	mesh.global_rotation.y = lerp_angle(mesh.global_rotation.y, SpringArm.global_rotation.y + input_angle, turn_speed * delta)

func _on_lock_on_area_entered(area: Node) -> void:
	if area.name == "LockOn":
		lock_on_target = area

func _lock_on(_delta: float)-> void:
	
	if not lock_on_activated: return
	if not is_instance_valid(lock_on_target): return
	
	var current_rotation = SpringArm.global_rotation
	SpringArm.look_at(lock_on_target.global_position - SpringArm.position, Vector3.UP)
	var new_rotation = SpringArm.global_rotation
	
	SpringArm.global_rotation.x = clamp(
		lerp_angle(current_rotation.x, new_rotation.x, LOCK_ON_SPEED * _delta),
		deg_to_rad(pitch_min_deg),
		deg_to_rad(pitch_max_deg)
		)
	SpringArm.global_rotation.y = lerp_angle(current_rotation.y, new_rotation.y, LOCK_ON_SPEED * _delta)
	mouse_delta = Vector2.ZERO

func _update_lock_on_indicator() -> void:
	
	if Input.is_action_just_pressed("lock_on"):
		lock_on_activated = !lock_on_activated
	
	if lock_on_activated and is_instance_valid(lock_on_target):
		LOCK_ON_INDICATOR.visible = true
		LOCK_ON_INDICATOR.position = unproject_position(lock_on_target.global_transform.origin)
	else:
		lock_on_activated = false
		LOCK_ON_INDICATOR.visible = false

func _ready() -> void:
	LOCK_ON_AREA.area_entered.connect(_on_lock_on_area_entered)
	
func _process(_delta: float) -> void:
	_update_lock_on_indicator()
			
func _physics_process(delta: float) -> void:
	
	if ignore_mouse_when_visible and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		mouse_delta = Vector2.ZERO
		return
	
	var look_left_right = Input.get_axis("look_left", "look_right")
	var look_up_down = Input.get_axis("look_down", "look_up")
	mouse_delta.x += look_left_right * MOUSE_SENSITIVITY * 3000
	mouse_delta.y -= look_up_down * MOUSE_SENSITIVITY * 3000
	
	_lock_on(delta)
	
	if mouse_delta.length() > 0:
		SpringArm.global_rotation.y -= mouse_delta.x * MOUSE_SENSITIVITY
		SpringArm.global_rotation.x = clamp(
			SpringArm.global_rotation.x - mouse_delta.y * MOUSE_SENSITIVITY,
			deg_to_rad(pitch_min_deg),
			deg_to_rad(pitch_max_deg)
		)
		mouse_delta = Vector2.ZERO
