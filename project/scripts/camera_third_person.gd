extends Camera3D
@export var PIVOT: Node3D
@export var MOUSE_SENSITIVITY = 0.003
@export var LOCK_ON_SPEED = 7
@export var LOCK_ON_OFFSET: float = 4.0
@export var LOCK_ON_AREA: Area3D
@export var LOCK_ON_INDICATOR: Node
var lock_on_activated = false
var lock_on_target: Area3D
var mouse_delta = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta += event.relative

func rotate_mesh_towards_camera_xz(delta: float, mesh: Node3D, input_vector: Vector2, turn_speed: float = 16) -> void:
	if input_vector.length() == 0: return
	var direction = Vector3(input_vector.x, 0, input_vector.y).normalized()
	var target_rotation = atan2(-direction.x, -direction.z) + PIVOT.rotation.y
	mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, turn_speed * delta)

func _on_lock_on_area_entered(area: Node) -> void:
	if area.name == "LockOn":
		lock_on_target = area

func _lock_on(_delta: float)-> void:
	
	if Input.is_action_just_pressed("lock_on"):
		lock_on_activated = !lock_on_activated
	
	if lock_on_activated and lock_on_target and is_instance_valid(lock_on_target):
		LOCK_ON_INDICATOR.visible = true;
		LOCK_ON_INDICATOR.position = unproject_position(lock_on_target.global_transform.origin)
		var target_position = lock_on_target.global_transform.origin - Vector3(0, LOCK_ON_OFFSET, 0)
		var current_rotation = PIVOT.global_transform.basis.get_rotation_quaternion()
		PIVOT.look_at(target_position + PIVOT.position, Vector3.UP)
		var new_rotation = PIVOT.global_transform.basis.get_rotation_quaternion()
		PIVOT.global_transform.basis = Basis(current_rotation.slerp(new_rotation, LOCK_ON_SPEED * _delta))
		mouse_delta = Vector2.ZERO
	else:
		lock_on_activated = false;
		LOCK_ON_INDICATOR.visible = false;

func _ready() -> void:
	LOCK_ON_AREA.area_entered.connect(_on_lock_on_area_entered)
	
#func _process(_delta: float) -> void:
	#pass #update the indicator here to not have lag 
			
func _physics_process(delta: float) -> void:
	
	var look_left_right = Input.get_axis("look_left", "look_right")
	var look_up_down = Input.get_axis("look_down", "look_up")
	mouse_delta.x += look_left_right * MOUSE_SENSITIVITY * 3000
	mouse_delta.y -= look_up_down * MOUSE_SENSITIVITY * 3000
	
	_lock_on(delta)
	
	if mouse_delta.length() > 0:
		
		var y_rot = Quaternion(Vector3.UP, -mouse_delta.x * MOUSE_SENSITIVITY)
		var x_rot = Quaternion(PIVOT.basis.x.normalized(), -mouse_delta.y * MOUSE_SENSITIVITY)
		PIVOT.basis = Basis(y_rot) * Basis(x_rot) * PIVOT.transform.basis

		mouse_delta = Vector2.ZERO
