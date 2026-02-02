extends CharacterBody3D
@export var ATTACKING_ENABLED = true

@export_group("Acceleration")
@export var GROUND_SPEED := 100.0
@export var AIR_SPEED  := 200.0
@export var MAX_SPEED = 12.35
@export var SPRINT_MULTIPLIER = 2.1
@export var SPEED_MULTIPLIER: float = 1.0

@export_group("Friction")
@export var GROUND_FRICTION := 11.0
@export var AIR_FRICTION := 2.0
func stop_horizontal_movement() -> void:
	velocity.x = 0
	velocity.z = 0

@export_group("Jumping")
@export var JUMP_VELOCITY = 15.0
@export var JUMP_MULTIPLIER = 1.0
@export var COYOTE_TIME: float = .35
@export var JUMP_BUFFER_TIME: float = .2
var falling = COYOTE_TIME;
var was_on_floor = true
var has_been_on_floor = false
var jump_buffer = 0;

@export_group("Falling")
@export var GRAVITY_MULTIPLIER = 4
@export var MAX_FALL_SPEED := 50.0 
@export var DESCEND_MULTIPLIER = 2.0

@export_group("Turning")
@export var MOUSE_SENSITIVITY = 0.003
@export var TURN_SPEED: float = 20.0
@export var TURN_MULTIPLIER: float = 1.0

@export_group("Stamina")
@export var STAMINA = 10
@export var MAX_STAMINA = 10
@export var STAMINA_RECOVERY: float = 20.0

@export_group("Shooting")
@export var MAX_SHOOTING_ENERGY: int = 5
@export var shooting_energy: int = MAX_SHOOTING_ENERGY
func change_shooting_energy(amount: int) -> void:
	shooting_energy = clamp(shooting_energy + amount, 0, MAX_SHOOTING_ENERGY)
func load_shooting_data() -> void:
	if Save.data.get("deaths",0) > Save.data.get("replenish_shooting_energy_at_death_count",0) \
	or Save.data.get("rests",0) > Save.data.get("replenish_shooting_energy_at_rest_count",0):
		Save.data.erase("shooting_energy")
		Save.data["replenish_shooting_energy_at_death_count"] = Save.data.get("deaths",0)
		Save.data["replenish_shooting_energy_at_rest_count"] = Save.data.get("rests",0)
	MAX_SHOOTING_ENERGY = Save.data.get("max_shooting_energy", MAX_SHOOTING_ENERGY)
	shooting_energy = Save.data.get("shooting_energy", MAX_SHOOTING_ENERGY)
	shooting_energy = min(shooting_energy, MAX_SHOOTING_ENERGY)
func try_shoot() -> void:
	if shooting_energy <= 0: return
	if not in_interruptible_animation(): return
	if not ATTACKING_ENABLED: return
	shooting_energy -= 1
	ANIM.play("SHOOT", 0.0)

@export_group("Healing") 
@export var MAX_HEAL_CHARGES: int = 1
@export var HEAL_AMOUNT: float = 5.0
@export var HITBOX: Area3D
@export var heal_charges: int = MAX_HEAL_CHARGES
func load_heal_data() -> void:
	if Save.data.get("deaths",0) > Save.data.get("replenish_heal_charges_at_death_count",0) \
	or Save.data.get("rests",0) > Save.data.get("replenish_heal_charges_at_rest_count",0):
		Save.data.erase("heal_charges")
		Save.data["replenish_heal_charges_at_death_count"] = Save.data.get("deaths",0)
		Save.data["replenish_heal_charges_at_rest_count"] = Save.data.get("rests",0)
	
	MAX_HEAL_CHARGES = Save.data.get("max_heal_charges", MAX_HEAL_CHARGES)
	HEAL_AMOUNT = Save.data.get("heal_amount", HEAL_AMOUNT)
	heal_charges = Save.data.get("heal_charges", MAX_HEAL_CHARGES)
func heal_hitbox() -> void:
	HITBOX.HEALTH = min(HITBOX.HEALTH + HEAL_AMOUNT, HITBOX.MAX_HEALTH)
func try_heal() -> void:
	if heal_charges <= 0: return
	if not is_on_floor(): return
	if not in_interruptible_animation(): return
	if not HITBOX: return
	if not "HEALTH" in HITBOX: return
	if not "MAX_HEALTH" in HITBOX: return
	#if HITBOX.HEALTH >= HITBOX.MAX_HEALTH: return
	heal_charges -= 1
	if ANIM: ANIM.play("HEAL", 0.0)

@export_group("References")
@export var CAMERA: Camera3D
@export var MESH: Node3D
@export var ANIM: AnimationPlayer
@export var MESH_ANIM: AnimationPlayer
@export var COLLISON_SHAPE: CollisionShape3D
@export var PARTICLES: Node3D
@export var FADE_IN_ANIM: AnimationPlayer
@export var SKILL_TREE: Node

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
		"HEAL",
		"BLOCK_ENTER",
		"BLOCK_EXIT",
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

func _exit_tree() -> void:
	
	Save.data["shooting_energy"] = shooting_energy
	Save.data["heal_charges"] = heal_charges
	
	if velocity.y < -20:
		Save.data["spawn_sound"] = "spawn_void"
	else:
		Save.data["spawn_sound"] = "spawn"
	Save.save_game()

func _ready() -> void:
	
	load_heal_data()
	load_shooting_data()
	
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
	
	if Input.is_action_just_pressed("shoot"): try_shoot()
	
func _physics_process(delta: float) -> void:

	if not was_on_floor and is_on_floor() and has_been_on_floor:
		if ANIM.current_animation in "PLUNGE_FALL":
			#print('Plunge')
			ANIM.play("PLUNGE", 0)
		
		$Squash.squish(.3, MESH)	
		if $Audio: $Audio.play_2d_sound(["land"])
		if PARTICLES: PARTICLES.spawn()
		
	was_on_floor = is_on_floor()
	if is_on_floor(): has_been_on_floor = true
	
	if ANIM.current_animation in "ESCAPE": return

	if ATTACKING_ENABLED and Input.is_action_just_pressed("attack"):
		if in_interruptible_animation() and not SKILL_TREE.visible:
			if is_on_floor():
				ANIM.play("WINDUP")
			else:
				ANIM.play("PLUNGE_FALL")
	
	if Input.is_action_pressed("block"):
		if in_interruptible_animation() and ANIM.current_animation not in ["BLOCK", "BLOCK_ENTER"]:
			#print(ANIM.playback_default_blend_time)
			ANIM.play("BLOCK_ENTER", 0.0)
	elif ANIM.current_animation == "BLOCK":
		if not Input.is_action_pressed("block") and ANIM.current_animation != "BLOCK_EXIT":
			ANIM.play("BLOCK_EXIT", 0.0)
			
	if Input.is_action_just_pressed("interact"): try_heal()
			
	if not is_on_floor(): # GRAVITY
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta * (DESCEND_MULTIPLIER if Input.is_action_pressed("descend") else 1.0)
	if velocity.y < -MAX_FALL_SPEED: velocity.y = -MAX_FALL_SPEED


	falling = 0.0 if is_on_floor() else falling + delta  # JUMP
	if Input.is_action_just_pressed("jump"): jump_buffer = JUMP_BUFFER_TIME;
	elif jump_buffer > 0: jump_buffer -= delta
	if jump_buffer > 0 and falling < COYOTE_TIME and not SKILL_TREE.visible: 
		if ANIM.current_animation and in_interruptible_animation():
			if JUMP_MULTIPLIER > 0:
				if $Audio: $Audio.play_2d_sound(["jump"])
				ANIM.play("JUMPING")
				$Squash.squish(-.3,MESH)	
				velocity.y = JUMP_VELOCITY * JUMP_MULTIPLIER
				falling = COYOTE_TIME
				jump_buffer = 0
				if PARTICLES: 
					PARTICLES.scene_to_spawn = 1
					PARTICLES.spawn()
	
	var keyboard_vector := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_forward", "keyboard_back")
	var controller_vector := Input.get_vector("controller_left", "controller_right", "controller_forward", "controller_back")
	var input_vector := keyboard_vector + controller_vector
	
	if SKILL_TREE.visible: input_vector = Vector2.ZERO
	
	if input_vector.length() > 0:
		
		var mesh_direction = -MESH.global_transform.basis.z
		var move_speed := (GROUND_SPEED if is_on_floor() else AIR_SPEED) 
		var speed_factor = 1.0
		if Input.is_action_pressed("sprint") or controller_vector.length() > 0.75:
			speed_factor = SPRINT_MULTIPLIER
		
		velocity.x += mesh_direction.x * move_speed * speed_factor * SPEED_MULTIPLIER * delta
		velocity.z += mesh_direction.z * move_speed * speed_factor * SPEED_MULTIPLIER * delta
		CAMERA.rotate_mesh_towards_camera_xz(delta, MESH, input_vector, TURN_SPEED * TURN_MULTIPLIER)
	
	var h = Vector2(velocity.x, velocity.z) # MAX SPEED
	if h.length() > MAX_SPEED:
		h = h.normalized() * MAX_SPEED
		velocity.x = h.x
		velocity.z = h.y
	
	move_and_slide() 
	
	var friction := GROUND_FRICTION if is_on_floor() else AIR_FRICTION # FRICTION
	friction *= delta
	velocity.x -= velocity.x * friction
	velocity.z -= velocity.z * friction
	
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
			
