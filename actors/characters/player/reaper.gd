extends CharacterBody3D
@export_group("Movement") 
@export_subgroup("Turning")
@export var MOUSE_SENSITIVITY: float = 0.003
@export var TURN_SPEED: float = 20.0
@export var TURN_MULTIPLIER: float = 1.0

@export_subgroup("Acceleration")
@export var GROUND_SPEED: float = 1.2
@export var AIR_SPEED: float = 1.2
@export var MAX_SPEED: float = 15.35
@export var SPRINT_MULTIPLIER: float = 2.1
@export var SPEED_MULTIPLIER: float = 1.0
@export var GROUND_FRICTION_PER_SECOND: float = 0.9 # fraction of remainingvelocity
@export var AIR_FRICTION_PER_SECOND: float = 0.9 # fraction of velocity lost
@export var RUN_DISABLED: bool = false	
@export var CONTROLLER_RUN_MULTIPLIER: float = 1
func apply_horizontal_friction() -> void: 
	# Use in physics process for time independence
	var friction: float = GROUND_FRICTION_PER_SECOND
	if not is_on_floor(): friction = AIR_FRICTION_PER_SECOND
	velocity.x *= friction
	velocity.z *= friction
func stop_horizontal_movement() -> void:
	velocity.x = 0
	velocity.z = 0
func clamp_horizontal_movement() -> void:
	if Vector2(velocity.x, velocity.z).length() <= MAX_SPEED: return
	var velocity_normalized = Vector2(velocity.x, velocity.z).normalized()
	velocity.x = velocity_normalized.x * MAX_SPEED
	velocity.z = velocity_normalized.y * MAX_SPEED
func get_keyboard_run_vector() -> Vector2:
	if RUN_DISABLED: return Vector2.ZERO
	return Input.get_vector("keyboard_left", "keyboard_right", "keyboard_forward", "keyboard_back")
func get_controller_run_vector() -> Vector2:
	if RUN_DISABLED: return Vector2.ZERO
	var input_vector = Input.get_vector("controller_left", "controller_right", "controller_forward", "controller_back")
	return input_vector * CONTROLLER_RUN_MULTIPLIER
func get_run_vector() -> Vector2:
	if RUN_DISABLED: return Vector2.ZERO
	var run_vector = get_controller_run_vector() + get_keyboard_run_vector()
	if run_vector.length() > 1: run_vector = run_vector.normalized()
	return run_vector
func is_walking() -> bool:
	var input_vector_length = get_controller_run_vector().length()	
	var is_controller_walking = input_vector_length > 0.0 and input_vector_length < 0.75
	return is_controller_walking or Input.is_action_pressed("walk")

func get_run_acceleration() -> Vector3:
	var input_vector: Vector2 = get_run_vector()
	var run_speed: float
	
	if is_on_floor(): run_speed = GROUND_SPEED
	else: run_speed = AIR_SPEED
	
	var speed_factor: float = SPRINT_MULTIPLIER
	if is_walking(): speed_factor = 1.0
		
	var acceleration: float = run_speed * speed_factor * SPEED_MULTIPLIER
	var run_vector = (Vector3(input_vector.x, 0, input_vector.y)).rotated(Vector3.UP, CAMERA.global_rotation.y)
	var run_velocity = run_vector * acceleration
	return 	run_velocity
func try_run(delta: float) -> void:
	if get_run_vector().length() == 0: return
	var acceleration = get_run_acceleration()
	velocity += acceleration
	if acceleration.length() > 0: CAMERA.rotate_mesh_towards_camera_xz(delta, MESH, get_run_vector(), TURN_SPEED * TURN_MULTIPLIER)

@export_subgroup("Jumping")
@export var JUMP_VELOCITY: float = 9.6
@export var JUMP_MULTIPLIER: float = 1.0
@export var VARIABLE_JUMP_TIME: float = .25
@export var COYOTE_TIME: float = 0.35
@export var JUMP_BUFFER_TIME: float = 0.2
var jump_buffer = 0;
var air_time = 0;
func update_jump_buffer(delta: float) -> void:	
	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER_TIME
	elif jump_buffer > 0:
		jump_buffer -= delta	
func try_jump() -> void:

	if jump_buffer > 0: 
		if air_time >= COYOTE_TIME: return
		if not in_interruptible_animation(): return
		if JUMP_MULTIPLIER == 0: return
		
		velocity.y = JUMP_VELOCITY * JUMP_MULTIPLIER
		
		if Input.is_action_pressed("jump") and air_time < VARIABLE_JUMP_TIME:
			jump_buffer = JUMP_BUFFER_TIME
		else:
			air_time = COYOTE_TIME
			jump_buffer = 0
		
		if is_on_floor():
			if $Audio: $Audio.play_2d_sound(["jump"])
			$Squash.squish(-.3)	
			ANIM.play("JUMPING")
			if PARTICLES: 
				PARTICLES.scene_to_spawn = 1
				PARTICLES.spawn()
	
@export_subgroup("Falling")
@export var GRAVITY_STRENGTH: float = 4.0
@export var GRAVITY_MULTIPLIER: float = 1.0
@export var MAX_FALL_SPEED: float = 50.0 
@export var DESCEND_MULTIPLIER: float = 5.0
@export var LAND_EFFECTS_COOLDOWN: float = 0.24
@export var STEP_UP_RAY: RayCast3D
func get_fall_velocity(delta: float) -> Vector3:
	var fall_vel = velocity + get_gravity() * (GRAVITY_MULTIPLIER * GRAVITY_STRENGTH) * delta
	if Input.is_action_pressed("descend"):
		fall_vel += get_gravity() * GRAVITY_MULTIPLIER * delta * (DESCEND_MULTIPLIER - 1.0)
	if fall_vel.y < -MAX_FALL_SPEED:
		fall_vel.y = -MAX_FALL_SPEED
	return fall_vel
func try_fall(delta: float) -> void:
	if is_on_floor():
		air_time = 0
	else:
		air_time += delta
		velocity = get_fall_velocity(delta)
func play_land_effects() -> void:
	if air_time > LAND_EFFECTS_COOLDOWN:
		$Squash.squish(.3)
		if $Audio: $Audio.play_2d_sound(["land"])
		if PARTICLES: PARTICLES.spawn()
func try_step_up() -> void:
	if not STEP_UP_RAY: return
	if not STEP_UP_RAY.is_colliding(): return
	if velocity.y > 1: return # Jumping ignore
	
	var hit_y: float = STEP_UP_RAY.get_collision_point().y
	var body_y: float = global_position.y
	if hit_y <= body_y: return
	
	# Make step up not work if its too steep an angle
	var hit_normal: Vector3 = STEP_UP_RAY.get_collision_normal()
	var up: Vector3 = Vector3.UP
	var angle: float = acos(clamp(hit_normal.dot(up), -1.0, 1.0))
	if angle > floor_max_angle: return

	# Return if would be in collision
	var new_pos: Vector3 = Vector3(global_position.x, hit_y, global_position.z)
	var params := PhysicsTestMotionParameters3D.new()
	params.from = global_transform
	params.motion = new_pos - global_position
	if PhysicsServer3D.body_test_motion(get_rid(), params): return
	
	play_land_effects()
	air_time = 0
	velocity.y = 0
	global_position.y = hit_y

@export_group("Combat") #
@export var STAMINA: float = 10
@export var MAX_STAMINA: float = 10
@export var STAMINA_RECOVERY: float = 30.0
@export var ATTACKING_DISABLED: bool = true
@export var PLUNGE_TIME: float = 0.03
func try_block() -> void:
	if Input.is_action_pressed("block"):
		if in_interruptible_animation() and ANIM.current_animation not in ["BLOCK", "BLOCK_ENTER"]:
			ANIM.play("BLOCK_ENTER", 0.0)
	elif ANIM.current_animation == "BLOCK":
		if not Input.is_action_pressed("block") and ANIM.current_animation != "BLOCK_EXIT":
			ANIM.play("BLOCK_EXIT", 0.0)
func try_attack() -> void:
	if ATTACKING_DISABLED: return
	if not Input.is_action_just_pressed("attack"): return
	if not in_interruptible_animation(): return
	
	if is_on_floor():
		ANIM.play("WINDUP")
	elif air_time > PLUNGE_TIME:
		ANIM.play("PLUNGE_FALL")
func try_plunge() -> void:
	if is_on_floor() or air_time < PLUNGE_TIME:
		if not ANIM.current_animation in "PLUNGE_FALL": return
		ANIM.play("PLUNGE", 0)

@export_subgroup("Dash")
@export var DASH_COOLDOWN: float = 0.0
@export var DASH_EXIT_SPEED: float = 3.0
@export var DASH_DISABLED: bool = false
var dash_cooldown_left: float = 0.0
func apply_dash_exit_velocity() -> void:
	var forward: Vector3 = -MESH.global_transform.basis.z.normalized()
	velocity += forward * DASH_EXIT_SPEED
func try_dash(delta: float) -> void:
	if DASH_DISABLED: return
	if ANIM and ANIM.current_animation == "DASH": return
	if dash_cooldown_left > 0: dash_cooldown_left -= delta
	if Input.is_action_just_pressed("dash") and dash_cooldown_left <= 0:
		if ANIM and in_interruptible_animation(): ANIM.play("DASH", 0.0)
	
@export_subgroup("Shooting")
@export var SHOOTING_DISABLED: bool = false
@export var MAX_SHOOTING_ENERGY: int = 1
@export var shooting_energy: int = MAX_SHOOTING_ENERGY
func change_shooting_energy(amount: int) -> void:
	shooting_energy = clamp(shooting_energy + amount, 0, MAX_SHOOTING_ENERGY)
func load_max_shooting_data() -> void:
	MAX_SHOOTING_ENERGY = Save.data.get("max_shooting_energy", MAX_SHOOTING_ENERGY)
func load_shooting_data() -> void:
	if Save.data.get("deaths",0) > Save.data.get("replenish_shooting_energy_at_death_count",0) \
	or Save.data.get("rests",0) > Save.data.get("replenish_shooting_energy_at_rest_count",0):
		Save.data.erase("shooting_energy")
		Save.data["replenish_shooting_energy_at_death_count"] = Save.data.get("deaths",0)
		Save.data["replenish_shooting_energy_at_rest_count"] = Save.data.get("rests",0)
	load_max_shooting_data()
	shooting_energy = Save.data.get("shooting_energy", MAX_SHOOTING_ENERGY)
func try_shoot() -> void:
	if SHOOTING_DISABLED: return
	if ATTACKING_DISABLED: return
	if not Input.is_action_just_pressed("shoot"): return
	if ANIM.current_animation == "SHOOT": return
	if shooting_energy <= 0: return
	if not is_on_floor(): return
	if not in_interruptible_animation(): return
	shooting_energy -= 1
	ANIM.play("SHOOT", 0.0)

@export_subgroup("Healing") 
@export var HITSHAPE: Area3D
@export var HEALING_DISABLED: bool = false
@export var MAX_HEAL_CHARGES: int = 1
@export var HEAL_AMOUNT: float = 5.0
@export var heal_charges: int = MAX_HEAL_CHARGES
func load_max_heal_data() -> void:
	MAX_HEAL_CHARGES = Save.data.get("max_heal_charges", MAX_HEAL_CHARGES)
func load_heal_data() -> void:
	if Save.data.get("deaths",0) > Save.data.get("replenish_heal_charges_at_death_count",0) \
	or Save.data.get("rests",0) > Save.data.get("replenish_heal_charges_at_rest_count",0):
		Save.data.erase("heal_charges")
		Save.data["replenish_heal_charges_at_death_count"] = Save.data.get("deaths",0)
		Save.data["replenish_heal_charges_at_rest_count"] = Save.data.get("rests",0)
	
	load_max_heal_data()
	HEAL_AMOUNT = Save.data.get("heal_amount", HEAL_AMOUNT)
	heal_charges = Save.data.get("heal_charges", MAX_HEAL_CHARGES)
func heal_hitshape() -> void:
	HITSHAPE.HEALTH = min(HITSHAPE.HEALTH + HEAL_AMOUNT, HITSHAPE.MAX_HEALTH)
func try_heal() -> void:
	if HEALING_DISABLED: return
	if heal_charges <= 0: return
	if not HITSHAPE: return
	if not Input.is_action_just_pressed("heal"): return
	if not is_on_floor(): return
	if not in_interruptible_animation(): return
	if not "HEALTH" in HITSHAPE: return
	if not "MAX_HEALTH" in HITSHAPE: return
	#if HITBOX.HEALTH >= HITBOX.MAX_HEALTH: return
	heal_charges -= 1
	if ANIM: ANIM.play("HEAL", 0.0)

@export_group("References")
@export var CAMERA: Camera3D
@export var MESH: Node3D
@export var COLLISON_SHAPE: CollisionShape3D
@export var PARTICLES: Node3D
@export var ANIM: AnimationPlayer
@export var MESH_ANIM: AnimationPlayer
@export var FADE_IN_ANIM: AnimationPlayer
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
	
	if not ANIM: return true
	return not ANIM.current_animation in [
		"HEAL",
		"BLOCK_ENTER",
		"BLOCK_EXIT",
		"DASH",
		"BLOCK",
		"SHOOT",
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
		"PIGLET_PET",
		"PIGLET_PAT",
		"LUST_INTRO"
	]

func reload_checkpoint() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file(Save.data["checkpoint_scene_path"])

func _exit_tree() -> void:
	
	Save.data["shooting_energy"] = shooting_energy
	Save.data["heal_charges"] = heal_charges
	
	if velocity.y < -20:
		Save.data["spawn_sound"] = "spawn_void"
	else:
		Save.data["spawn_sound"] = "spawn"
	Save.save_game()

func _ready() -> void:
	
	load_shooting_data()
	load_heal_data()
	Save.save_data_updated.connect(load_max_shooting_data)
	Save.save_data_updated.connect(load_max_heal_data)
	
	if Save.data.has("door_node_name"):		
		var door_node = get_tree().root.find_child(Save.data["door_node_name"], true, false)
		if door_node:
			if door_node.START: 
				global_transform = door_node.START.global_transform
				CAMERA.last_orientation = CAMERA.global_basis
		FADE_IN_ANIM.play("DOOR_FADE_IN")
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
	
	if ANIM.current_animation in "ESCAPE": return
	
	if is_on_floor(): play_land_effects()
	try_fall(delta)
	try_run(delta)
	update_jump_buffer(delta)
	try_jump()
	try_plunge()
	try_attack()
	try_block()	
	try_heal()
	try_shoot()
	try_step_up()
	clamp_horizontal_movement()
	apply_horizontal_friction()
	try_dash(delta)
	move_and_slide() 
	if in_interruptible_animation(): 
		if air_time < 0.1: 
			if get_run_vector().length() > 0:
				if is_walking():
					ANIM.play("WALK", 0.0, 1, false)
				else:
					ANIM.play("RUN", 0.0, 1, false)
			else:
				ANIM.play("IDLE", 0, 1, false)
		else:
			if (velocity.y < 0):
				ANIM.play("FALL")
			else:
				ANIM.play("JUMPING")
			
