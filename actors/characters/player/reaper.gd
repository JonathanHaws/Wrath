extends CharacterBody3D

@export_group("Movement")
@export var SPEED = 5.35
@export var SPRINT_MULTIPLIER = 2.1
@export var SPEED_FRICTION = 0.9999999999
@export var JUMP_VELOCITY = 15.0
@export var JUMP_MULTIPLIER = 1.0
@export var GRAVITY_MULTIPLIER = 4
@export var MOUSE_SENSITIVITY = 0.003
@export var TURN_SPEED: float = 20.0
@export var TURN_MULTIPLIER: float = 1.0
@export var SPEED_MULTIPLIER: float = 1.0
@export var COYOTE_TIME: float = .35
@export var JUMP_BUFFER_TIME: float = .2
@export var SPIN_DAMAGE_MULTIPLIER = 1.5
@export var DESCEND_MULTIPLIER = 2.0

@export_group("References")
@export var CAMERA: Camera3D
@export var MESH: Node3D
@export var ATTACK_AREA: Area3D
@export var ANIM: AnimationPlayer
@export var MESH_ANIM: AnimationPlayer
@export var COLLISON_SHAPE: CollisionShape3D
@export var PARTICLES: Node3D
@export var STAMINA = 10
@export var MAX_STAMINA = 10
@export var STAMINA_RECOVERY: float = 20.0

var falling = COYOTE_TIME;
var was_on_floor = true
var has_been_on_floor = false
var jump_buffer = 0;

func increase_damage_each_spin():
	if ATTACK_AREA: 
		ATTACK_AREA.damage_multiplier *= SPIN_DAMAGE_MULTIPLIER
		#print(ATTACK_AREA.damage_multiplier, ATTACK_AREA.damage)
	
func reset_spin_damage():
	if ATTACK_AREA: ATTACK_AREA.damage_multiplier = 1

func reload_checkpoint() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file(Save.data["checkpoint_scene_path"])

func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "WINDOWN":
		ANIM.play("IDLE", 0.0, 1, false)
		ANIM.seek(0, true)
		MESH_ANIM.playback_default_blend_time = 0.2

	if animation_name == "SPIN":
		if Input.is_action_pressed("attack") and STAMINA > 0:
			MESH_ANIM.playback_default_blend_time = 0.0
			ANIM.play("SPIN", 0.0, 1, false)
			ANIM.seek(0, true)
			STAMINA -= 10
			
		else:
			MESH_ANIM.playback_default_blend_time = 0.0
			ANIM.play("WINDOWN", 0.0, 1, false)
			ANIM.seek(0, true) 
	
	if animation_name == "WINDUP":
		MESH_ANIM.playback_default_blend_time = 0.0
		ANIM.play("SPIN", 0.0, 1, false)
		ANIM.seek(0, true) 
		STAMINA -= 10

func in_interruptible_animation() -> bool:
	return not ANIM.current_animation in [
		"WINDUP",
		"WINDOWN",
		"SPIN",
		"DEATH",
		"FALL_DEATH",
		"HURT",
		"PLUNGE_FALL",
		"PLUNGE",
		"DOOR",
		"REST",
		"LADDER_ENTER",
		"LADDER",
		"LADDER_EXIT",
		"ESCAPE",
		"INTRODUCTION",
		"GLUTTONY_INTRO",
		"PIGLET_PICKUP",
	]

func _exit_tree() -> void:
	if velocity.y < -20:
		Save.data["spawn_sound"] = "spawn_void"
	else:
		Save.data["spawn_sound"] = "spawn"
	Save.save_game()

func _ready() -> void:
	
	if Save.data.has("door_node_name"):		
		var door_node = get_tree().root.find_child(Save.data["door_node_name"], true, false)
		if door_node:
			if door_node.START: 
				global_transform = door_node.START.global_transform
		$FadeIn.play("DOOR_FADE_IN")
		Save.data.erase("door_node_name")
		Save.save_game()
		return
	
	if Save.data.has("checkpoint_scene_path"):
		if get_tree().current_scene and get_tree().current_scene.scene_file_path != Save.data["checkpoint_scene_path"]:
			get_tree().call_deferred("change_scene_to_file", Save.data["checkpoint_scene_path"])
			return
	if not Save.data.has("checkpoint_scene_path"):
		Save.data["checkpoint_scene_path"] = get_tree().current_scene.scene_file_path
	if Save.data.has("checkpoint_node_path"):
		var checkpoint_node = get_node_or_null(Save.data["checkpoint_node_path"])
		if checkpoint_node: checkpoint_node.load_checkpoint(self)
		
	if not Save.data.has("spawn_sound"):
		Save.data["spawn_sound"] = "spawn_new"
	if $Audio: $Audio.play_2d_sound([Save.data["spawn_sound"]])

func _process(_delta)-> void:
	if not Input.is_action_pressed("attack"): 
		STAMINA = clamp(STAMINA + STAMINA_RECOVERY * _delta, 0, MAX_STAMINA)

func _physics_process(delta: float) -> void:

	if not was_on_floor and is_on_floor() and has_been_on_floor:
		if ANIM.current_animation in "PLUNGE_FALL":
			#print('Plunge')
			ANIM.play("PLUNGE", 0)
		
		$Squash.squish(.23, MESH)	
		if $Audio: $Audio.play_2d_sound(["land"], 0.9, 1.1)
		if PARTICLES: PARTICLES.spawn()
		
	was_on_floor = is_on_floor()
	if is_on_floor(): has_been_on_floor = true
	
	if ANIM.current_animation in "ESCAPE": return

	if Input.is_action_just_pressed("attack"): # ATTACK
		if in_interruptible_animation():
			if is_on_floor():
				ANIM.play("WINDUP")
			else:
				ANIM.play("PLUNGE_FALL")
		
	if not is_on_floor(): # GRAVITY
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta * (DESCEND_MULTIPLIER if Input.is_action_pressed("descend") else 1.0)

	falling = 0.0 if is_on_floor() else falling + delta

	if Input.is_action_just_pressed("jump"): jump_buffer = JUMP_BUFFER_TIME;
	elif jump_buffer > 0: jump_buffer -= delta

	if jump_buffer > 0 and falling < COYOTE_TIME: # JUMP
		if ANIM.current_animation and in_interruptible_animation():
			if JUMP_MULTIPLIER > 0:
				if $Audio: $Audio.play_2d_sound(["jump"], 2.0)
				ANIM.play("JUMPING")
				$Squash.squish(-.23,MESH)	
				velocity.y = JUMP_VELOCITY * JUMP_MULTIPLIER
				falling = COYOTE_TIME
				jump_buffer = 0
				if PARTICLES: PARTICLES.spawn(1)
	
	var keyboard_vector := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_forward", "keyboard_back")
	var controller_vector := Input.get_vector("controller_left", "controller_right", "controller_forward", "controller_back")
	var input_vector := keyboard_vector + controller_vector
	
	if input_vector.length() > 0:
		var mesh_direction = -MESH.global_transform.basis.z
		var speed_factor = 1.0
		if Input.is_action_pressed("sprint") or controller_vector.length() > 0.75:
			speed_factor = SPRINT_MULTIPLIER

		velocity.x = mesh_direction.x * SPEED * SPEED_MULTIPLIER * speed_factor
		velocity.z = mesh_direction.z * SPEED * SPEED_MULTIPLIER * speed_factor

		CAMERA.rotate_mesh_towards_camera_xz(delta, MESH, input_vector, TURN_SPEED * TURN_MULTIPLIER)
	else:
		velocity.x = 0 
		velocity.z = 0
	
	move_and_slide() 
	
	if in_interruptible_animation(): 
		if is_on_floor(): 
			if input_vector.length() > 0:
				if (Input.is_action_pressed("sprint") or controller_vector.length() > 0.75):
					ANIM.play("RUN", 0.0, 1, false)
				else:
					ANIM.play("WALK", 0.0, 1, false)
			else:
				ANIM.play("IDLE", 0, 1, false)
		else:
			if (velocity.y < 0):
				ANIM.play("FALL")
			else:
				ANIM.play("JUMPING")
			
