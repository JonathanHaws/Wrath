extends CharacterBody3D

@export_group("Difficulty")
@export var MAX_HEALTH: int = 50
@export var SPEED = 9.0
@export var JUMP_ATTACK_PERCENTAGE = 0.8
@export var SLAM_ATTACK_PERCENTAGE = 2.2
@export var TRACKING_SPEED: float = 5.0
@export var TRACKING_MULTIPLIER: float = 1.0
@export var ATTACK_ANIMATION: Array[String] = []
@export var ATTACK_RADIUS: Array[float] = []
@export var ATTACK_LIKELEHOOD: Array[Curve] = []

@export_group("References")
@export var REAPER: CharacterBody3D
@export var ANIM: AnimationPlayer
@export var MESH_ANIM: AnimationPlayer
@export var MESH: Node3D
@export var LOCK_ON: Node3D
@export var NAV_REGION: NavigationRegion3D 
@export var NAV_AGENT: NavigationAgent3D
@export var PROGRESSION_AREA: Area3D 
@export var HURT_PARTICLE_SCENE: PackedScene
@export var DEATH_PARTICLE_SCENE: PackedScene
@export var BODY_MATERIAL: ShaderMaterial
@export var DAMAGE_NUMBER: PackedScene
@export var MUSIC: Node

var health = MAX_HEALTH
var triggered = false;
var target_direction = Vector3.ZERO

func root_motion() -> void: # Make sure mesh anim uses physics callback or will not be moving enough
	var root_motion_position = MESH_ANIM.get_root_motion_position() 
	var transformed_root_motion = MESH.global_transform.basis * root_motion_position
	global_transform.origin += transformed_root_motion; 
func track_towards_direction(delta: float) -> void:
	if target_direction.length_squared() < 0.0001: return
	if target_direction.normalized().is_equal_approx(Vector3.ZERO): return
	var target_basis = Basis.looking_at(target_direction, Vector3.UP)
	var interpolated_basis = MESH.global_transform.basis.slerp(target_basis, TRACKING_SPEED * TRACKING_MULTIPLIER * delta)
	MESH.global_transform.basis = interpolated_basis.orthonormalized()

func hurt(_damage: float = 0, _group: String = "", _position: Vector3 = Vector3.ZERO) -> void:
	WorldUI.show_symbol(global_position, DAMAGE_NUMBER, 140.0, "Node2D/Label", _damage)
	SlowMotion.impact(.04)
	Shake.tremor(2)
	if $Audio: $Audio.play_2d_sound(["hit_1", "hit_2", "hit_3"], 0.9, 1.1)
	Particles.spawn(_position, HURT_PARTICLE_SCENE)
	if health <= 0:
		PROGRESSION_AREA.monitoring = true
		ANIM.play("DEATH",0,1,false)
		Save.data["wrath_defeated"] = true
		Save.save_game()	
		MUSIC._connect_exit_queue_free()

func shake_camera() -> void:
	Shake.tremor(3)

func _on_trigger_area_body_entered(body: Node) -> void:
	if body != REAPER: return
	if triggered: return
	triggered = true
	ANIM.play("INTRO")
	
func _ready() -> void:
	
	health = MAX_HEALTH
	target_direction = -global_transform.basis.z.normalized()
	if Save.data.has("wrath_defeated") and Save.data["wrath_defeated"]:
		queue_free()
		MUSIC.queue_free()
		PROGRESSION_AREA.monitoring = true

func _physics_process(delta: float) -> void:
	
	if REAPER and REAPER.health < 0:
		MUSIC._connect_exit_queue_free()

	if health <= 0: return

	root_motion()
	if health > 0: 
		move_and_slide()
	else:
		velocity = Vector3(0, 0, 0)
	if not is_on_floor(): velocity += get_gravity() * delta
	if not triggered or health <= 0: return;
	if REAPER.health <= 0: MUSIC._connect_exit_queue_free()
	track_towards_direction(delta)
	target_direction = (REAPER.global_transform.origin - global_transform.origin).normalized()

	if REAPER.health <= 0:
		MUSIC._connect_exit_queue_free()
		return

	if ANIM.current_animation == "CHASE" and global_transform.origin.distance_to(REAPER.global_transform.origin) > 2.0:
		NAV_AGENT.target_position = REAPER.global_transform.origin
		var direction = NAV_AGENT.get_next_path_position() - global_transform.origin
		direction.y = 0  # Ignore vertical movement
		velocity.x = direction.normalized().x * SPEED
		velocity.z = direction.normalized().z * SPEED
		if direction.length() > 0: target_direction = direction
	else:
		velocity.x = 0
		velocity.z = 0

	if not ANIM.current_animation in ["CHASE"]: return
		
	var indices = range(ATTACK_ANIMATION.size())  
	indices.shuffle();  #print(indices) # randomly sort attacks to distrubte priorty
	for i in indices:
		var normalized_distance = clamp(global_transform.origin.distance_to(REAPER.global_transform.origin) / ATTACK_RADIUS[i], 0.0, 1.0)
		var attack_likelihood = ATTACK_LIKELEHOOD[i].sample(randf()) * (1.0 - normalized_distance)
		attack_likelihood *= delta 
		attack_likelihood *= (1 / delta)
		if randf() < attack_likelihood:
			
			# Avoids 3 Animations being played at the same time I think was leading to visual bug with blending. Waits till only 1 animation is playing. Not sure if this is truly the issue tho
			if ANIM.get_current_animation_length() - ANIM.get_current_animation_position() < ANIM.get_playing_speed() * ANIM.get_blend_time(ANIM.current_animation, ATTACK_ANIMATION[i]): return

			ANIM.play(ATTACK_ANIMATION[i])
			break
		
