extends Node
@export var shake = 0.0
@export var decay_rate = 8.0
@export var max_shake = 10.0
@export var TREMOR_STRENGTH: float = 1.0
@export var TARGET_GROUP: String = "player"
var noise := FastNoiseLite.new()
var shake_offset := Vector3.ZERO
	
func _ready():
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 2.0

func tremor(scale: float = 1.0) ->void:
	shake += scale
	
func _physics_process(delta):
	var current_camera := get_viewport().get_camera_3d()
	if !current_camera: return
	current_camera.rotation_degrees -= shake_offset # Remove previous frame's shake
	if shake > 0.0:
		shake -= decay_rate * delta
		shake = max(shake, 0.0)
		var time = Engine.get_physics_frames()
		var shake_x = noise.get_noise_2d(time * 0.05, 0.0)
		var shake_y = noise.get_noise_2d(time * 0.05, 1000.0) 
		var shake_z = noise.get_noise_2d(time * 0.05, 2000.0) 
		shake_offset.x = clamp(shake_x * shake, -max_shake, max_shake)
		shake_offset.y = clamp(shake_y * shake, -max_shake, max_shake)
		shake_offset.z = clamp(shake_z * shake, -max_shake, max_shake)
		current_camera.rotation_degrees += shake_offset
		
func _on_body_entered(body) -> void:
	if body.is_in_group(TARGET_GROUP):
		#print('registering')
		tremor(TREMOR_STRENGTH)

func continious_tremor(strength: float, duration: float = 1.0) -> void:
	var old_rate = decay_rate
	decay_rate = 0
	shake = strength
	await get_tree().create_timer(duration, true, false, true).timeout
	decay_rate = old_rate
