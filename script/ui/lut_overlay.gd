extends ColorRect
@export var player_body_group: String = "player_body"
@export var area_lut_textures: Array[Texture3D]
@export var area_lut_groups: Array[String] = ["lut_lust"]
@export var blend_speed: float = 1.0
var target_blend: float = 0.0
var old_target_blend: float = target_blend
var current_blend_speed: float = blend_speed
var mat: ShaderMaterial

func _ready():
	#await get_tree().physics_frame
	
	mat = material as ShaderMaterial
	for area_group_name in area_lut_groups:
		for area in get_tree().get_nodes_in_group(area_group_name):
			area.body_entered.connect(_on_lut_area_entered)
			area.body_exited.connect(_on_lut_area_exited)

func _on_lut_area_entered(body):
	if not body.is_in_group(player_body_group): return
	#2print(body.name, ' entered lut area')
	_tween_target_blend(1)

func _on_lut_area_exited(body):
	if not body.is_in_group(player_body_group): return
	#print(body.name, ' exited lut area')
	_tween_target_blend(0)

func _tween_target_blend(target: float, speed: float = current_blend_speed):
	if mat == null: return
	var tween = create_tween()
	tween.tween_property(self, "target_blend", target, speed)
	

func _process(_delta):
	
	#print(target_blend)
	if not old_target_blend == target_blend:
		mat.set_shader_parameter("blend", target_blend)
	old_target_blend = target_blend
	
	if Input.is_action_just_pressed("toggle_lut") and OS.is_debug_build():
		visible = !visible
		
	if Input.is_action_just_pressed("blend_lut") and OS.is_debug_build():
		if current_blend_speed == blend_speed: current_blend_speed = 0
		else: current_blend_speed = blend_speed
			
	
	#if Input.is_action_pressed("blend_lut") and OS.is_debug_build(): 
		#
		#var b = mat.get_shader_parameter("blend")
		#b += 0.01        # increment
		#b = fmod(b, 1.0) # wrap around at 1
		#mat.set_shader_parameter("blend", b)
		#
