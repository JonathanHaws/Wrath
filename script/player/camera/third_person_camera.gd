extends Camera3D
@export_group("Camera")
@export_range(-90.0, 90.0, 1.0, "Degrees") var pitch_min_deg: float = -80.0
@export_range(-90.0, 90.0, 1.0, "Degrees") var pitch_max_deg: float = 80.0

@export var Root: Node3D
@export var Body: Node3D
@export var SpringArm: SpringArm3D
#@export var EXCLUDED_BODY: PhysicsBody3D ## If the camera is between players body and wall. But the player is against the wall. the spring arm has to phase into 1. 
@export var MOUSE_SENSITIVITY: float = 0.003
@export var CONTROLLER_SENSITIVITY: float = 0.07
@export var SENSITIVITY_MULTIPLIER: float = 1.0
@export var TOP_LEVEL_ROTATION: bool = true ## For ignoring rotation tweens on interactions... Or any external influence to orientation

@export_group("FOV Lerp")
@export var lerp_fov: float = true
@export var lerp_speed: float = 0.12
@export var target_fov: float = 80.0
@export var default_fov: float = 65.0
@export var running_fov: float = 74.0

@export_group("Target_Lerp")
@export var TARGET_NODE: Node3D ## Used for when smooth camera is desired instead of instant snapping to the end of the spring arm. REQUIRED Use top level on this Camera node
@export var SNAP_SPEED: float = 10.0 ## How quickly the camera moves to the target node
var initial_snap: bool = false
var mouse_delta = Vector2.ZERO

func set_camera_transform(new_transform: Transform3D) -> void:
	Root.transform = Transform3D.IDENTITY
	Root.global_position = new_transform.origin
	Body.transform = new_transform
	Body.position = Vector3.ZERO
	SpringArm.global_basis = new_transform.basis
	transform = new_transform

func _ready() -> void:
	if Config: MOUSE_SENSITIVITY = Config.load_setting("controls", "mouse_sensitivity", MOUSE_SENSITIVITY)
	if Config: CONTROLLER_SENSITIVITY = Config.load_setting("controls", "controller_sensitivity", CONTROLLER_SENSITIVITY)
	#if EXCLUDED_BODY: SpringArm.add_excluded_object(EXCLUDED_BODY)
	set_transform(TARGET_NODE.global_transform)
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta += event.screen_relative * Engine.time_scale

func rotate_mesh_towards_camera_xz(delta: float, mesh: Node3D, input_vector: Vector2, turn_speed: float = 16) -> void:
	if input_vector.length() == 0: return
	var input_angle = atan2(-input_vector.x, -input_vector.y)
	mesh.global_rotation.y = lerp_angle(mesh.global_rotation.y, SpringArm.global_rotation.y + input_angle, turn_speed * delta)
			
func _physics_process(_delta: float) -> void:
	Root.global_position = Body.global_position
	Body.position = Vector3.ZERO
	
	#print(SpringArm.get_hit_length())
	#print(position)
	
	if lerp_fov: fov = lerp(fov, target_fov, lerp_speed)
	if TARGET_NODE: global_transform = global_transform.interpolate_with(TARGET_NODE.global_transform, SNAP_SPEED * _delta)

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: 
		mouse_delta = Vector2.ZERO
		return
	var mouse_sens = MOUSE_SENSITIVITY * SENSITIVITY_MULTIPLIER
	var controller_sens = CONTROLLER_SENSITIVITY * SENSITIVITY_MULTIPLIER
	mouse_delta.x *=  mouse_sens 
	mouse_delta.y *=  mouse_sens 
	var look_left_right = Input.get_axis("look_left", "look_right")
	var look_up_down = Input.get_axis("look_down", "look_up")
	mouse_delta.x += look_left_right * controller_sens
	mouse_delta.y -= look_up_down * controller_sens
	
	if mouse_delta.length() > 0:
		var new_x = SpringArm.global_rotation.x - mouse_delta.y 
		var new_y = SpringArm.global_rotation.y - mouse_delta.x 
		new_x = clamp(new_x, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg)) #Constrain 
		SpringArm.global_rotation.x = new_x
		SpringArm.global_rotation.y = new_y
		mouse_delta = Vector2.ZERO
		
