extends Area3D

@export var lut_inside: Texture3D
@export var lut_outside: Texture3D
@export var player_body_group: String = "player"

var env: Environment
var count: int = 0
var luts_enabled: bool = true

func _ready():
	env = get_viewport().get_world_3d().environment
	env.adjustment_enabled = true
	
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body):
	if not luts_enabled or not body.is_in_group(player_body_group):
		return
	#print('player entered lut area')
	count += 1
	_apply()

func _on_exit(body):
	if not luts_enabled or not body.is_in_group(player_body_group):
		return
	#print('player exited lut area')
	count -= 1
	if count < 0: count = 0
	_apply()

func _apply():
	if not luts_enabled:
		env.adjustment_color_correction = null
	else:
		env.adjustment_color_correction = (lut_inside if count > 0 else lut_outside)

func _process(delta):
	if Input.is_action_just_pressed("toggle_lut"):
		luts_enabled = !luts_enabled
		_apply()

func disable_luts():
	luts_enabled = false
	env.adjustment_color_correction = null

func enable_luts():
	luts_enabled = true
	_apply()
