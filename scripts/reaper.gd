extends CharacterBody3D

@export_group("Movement")
@export var SPEED = 5.35
@export var SPRINT_MULTIPLIER = 2.1
@export var SPEED_FRICTION = 0.9999999999
@export var JUMP_VELOCITY = 14.0
@export var GRAVITY_MULTIPLIER = 4
@export var MOUSE_SENSITIVITY = 0.003
@export var TURN_SPEED: float = 20.0
@export var TURN_MULTIPLIER: float = 1.0
@export var SPEED_MULTIPLIER: float = 1.0
@export var COYOTE_TIME: float = .4
@export var JUMP_BUFFER_TIME: float = .2
@export var IN_CUTSCENE = false
@export var BASE_DAMAGE = 50
@export var DAMAGE_MULTIPLIER = 1
@export var SPIN_MULTIPLIER = 1.5
@export var DESCEND_MULTIPLIER = 2.0

@export_group("References")
@export var CAMERA: Camera3D
@export var MESH: Node3D
@export var ATTACK_AREA: Area3D
@export var ANIM: AnimationPlayer
@export var MESH_ANIM: AnimationPlayer
@export var COLLISON_SHAPE: CollisionShape3D
@export var PARTICLES: Node3D
@export var HEALTH = 15
@export var MAX_HEALTH = 15
@export var STAMINA = 10
@export var MAX_STAMINA = 10
@export var STAMINA_RECOVERY: float = 20.0

var falling = COYOTE_TIME;
var was_on_floor = true
var has_been_on_floor = false
var jump_buffer = 0;

func increase_damage_each_spin():
	DAMAGE_MULTIPLIER *= SPIN_MULTIPLIER
	ATTACK_AREA.damage = BASE_DAMAGE * DAMAGE_MULTIPLIER

func reset_spin_damage():
	DAMAGE_MULTIPLIER = 1
	ATTACK_AREA.damage = BASE_DAMAGE * DAMAGE_MULTIPLIER

func hurt(_damage: float = 0, _group: String = "", _position: Vector3 = Vector3.ZERO) -> void:
	if HEALTH > 0:
		if (_group != "kill_floor"):
			ANIM.play("HURT")
			Shake.tremor(3)
			SlowMotion.impact(.2)
			if $Audio: $Audio.play_2d_sound(["hurt"],)
	else: # death
		Save.data["deaths"] += 1
		if _group == "kill_floor":
			if ANIM.current_animation == "FALL_DEATH": return
			Save.data["spawn_sound"] = "spawn_void"
			ANIM.play("FALL_DEATH")	
		else:
			if ANIM.current_animation == "DEATH": return
			if $Audio: $Audio.play_2d_sound(["hurt"])
			await SlowMotion.impact(.3,0)
			Save.data["spawn_sound"] = "spawn"
			ANIM.play("DEATH")	
		Save.save_game()

func reload_checkpoint() -> void:
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
	return not ANIM.current_animation in ["WINDUP", "SPIN", "WINDOWN", "DEATH", "FALL_DEATH", "HURT", "PLUNGE_FALL", "PLUNGE"]

func _exit_tree() -> void:
	if HEALTH > 0:
		Save.data["health"] = HEALTH
	else: 
		Save.data.erase("health")

func _ready() -> void:
	
	if Save.data.has("max_stamina"):
		MAX_STAMINA = Save.data["max_stamina"]
	
	if Save.data.has("max_health"):
		MAX_HEALTH = Save.data["max_health"]
		
	if Save.data.has("health"):
		HEALTH = Save.data["health"]
	else:
		HEALTH = MAX_HEALTH
	
	if not Save.data.has("deaths"):
		Save.data["deaths"] = 0
	

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
		if checkpoint_node: global_transform = checkpoint_node.global_transform
		
	if not Save.data.has("spawn_sound"):
		Save.data["spawn_sound"] = "spawn_new"
	if $Audio: $Audio.play_2d_sound([Save.data["spawn_sound"]])

func _process(_delta)-> void:
	if not Input.is_action_pressed("attack"): 
		STAMINA = clamp(STAMINA + STAMINA_RECOVERY * _delta, 0, MAX_STAMINA)

func _physics_process(delta: float) -> void:
	
	if IN_CUTSCENE: 
		ANIM.stop()
		return

	if not was_on_floor and is_on_floor() and has_been_on_floor:
		if ANIM.current_animation in "PLUNGE_FALL":
			#print('Plunge')
			ANIM.play("PLUNGE", 0)
		
		Squash.squish(.23, MESH)	
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
		
	if not is_on_floor() and not God.mode: # GRAVITY
		velocity += get_gravity() * GRAVITY_MULTIPLIER * delta * (DESCEND_MULTIPLIER if Input.is_action_pressed("descend") else 1.0)

	falling = 0.0 if is_on_floor() else falling + delta

	if Input.is_action_just_pressed("jump"): jump_buffer = JUMP_BUFFER_TIME;
	elif jump_buffer > 0: jump_buffer -= delta

	if jump_buffer > 0 and falling < COYOTE_TIME: # JUMP

		if ANIM.current_animation and in_interruptible_animation():
				
			if $Audio: $Audio.play_2d_sound(["jump"], 2.0)
			ANIM.play("JUMPING")
			Squash.squish(-.23,MESH)	
			velocity.y = JUMP_VELOCITY
			falling = COYOTE_TIME
			jump_buffer = 0
			if PARTICLES: PARTICLES.spawn(1)
	
	var keyboard_vector := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_forward", "keyboard_back")
	var controller_vector := Input.get_vector("controller_left", "controller_right", "controller_forward", "controller_back")
	var input_vector := keyboard_vector + controller_vector
	
	if input_vector.length() > 0:
		if God.mode:
			var direction := -CAMERA.global_transform.basis.z.normalized()
			velocity = direction * 3000 *delta
			$CollisionShape3D.disabled = true	
		else:
			$CollisionShape3D.disabled = false
			var mesh_direction = Vector3(0, 0, -1).rotated(Vector3.UP, MESH.rotation.y + global_transform.basis.get_euler().y)
			if (Input.is_action_pressed("sprint") or controller_vector.length() > 0.75):
				velocity.x = mesh_direction.x * SPEED * SPRINT_MULTIPLIER * SPEED_MULTIPLIER
				velocity.z = mesh_direction.z * SPEED * SPRINT_MULTIPLIER * SPEED_MULTIPLIER
			else:
				velocity.x = mesh_direction.x * SPEED * SPEED_MULTIPLIER
				velocity.z = mesh_direction.z * SPEED * SPEED_MULTIPLIER

		CAMERA.rotate_mesh_towards_camera_xz(delta, MESH, input_vector, TURN_SPEED * TURN_MULTIPLIER)
	else:
		velocity.x = 0 
		velocity.z = 0
		if God.mode: velocity.y = 0 
	
	move_and_slide()  # never move and slide if velocity is = 0
	
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
				
