extends Camera3D
@export_group("Camera")
@export_range(-90.0, 90.0, 1.0, "Degrees") var pitch_min_deg: float = -80.0
@export_range(-90.0, 90.0, 1.0, "Degrees") var pitch_max_deg: float = 80.0
@export var SpringArm: SpringArm3D
@export var MOUSE_SENSITIVITY: float = 0.003
@export var CONTROLLER_SENSITIVITY: float = 0.07
@export var SENSITIVITY_MULTIPLIER: float = 1.0
@export var TOP_LEVEL_ROTATION: bool = true ## For ignoring rotation tweens on interactions... Or any external influence to orientation
var mouse_delta = Vector2.ZERO
var last_orientation := Basis.IDENTITY

func _ready() -> void:
	last_orientation = SpringArm.global_transform.basis
	if Config: MOUSE_SENSITIVITY = Config.load_setting("controls", "mouse_sensitivity", MOUSE_SENSITIVITY)
	if Config: CONTROLLER_SENSITIVITY = Config.load_setting("controls", "controller_sensitivity", CONTROLLER_SENSITIVITY)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta += event.screen_relative * Engine.time_scale

func rotate_mesh_towards_camera_xz(delta: float, mesh: Node3D, input_vector: Vector2, turn_speed: float = 16) -> void:
	if input_vector.length() == 0: return
	var input_angle = atan2(-input_vector.x, -input_vector.y)
	mesh.global_rotation.y = lerp_angle(mesh.global_rotation.y, SpringArm.global_rotation.y + input_angle, turn_speed * delta)
			
func _physics_process(_delta: float) -> void:
	
	if TOP_LEVEL_ROTATION:
		SpringArm.global_transform.basis = last_orientation
	
	#print(position)
	
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
		
	last_orientation = SpringArm.global_transform.basis
