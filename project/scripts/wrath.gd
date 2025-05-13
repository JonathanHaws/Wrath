extends CharacterBody3D

@export_group("Difficulty")
@export var MAX_HEALTH: int = 2500
@export var SPEED = 9.0
@export var TRACKING_SPEED: float = 5.0
@export var TRACKING_MULTIPLIER: float = 1.0

@export_group("References")
@export var TARGET: Node3D
@export var ANIM: AnimationPlayer
@export var MESH_ANIM: AnimationPlayer
@export var MESH: Node3D
@export var NAV_REGION: NavigationRegion3D 
@export var NAV_AGENT: NavigationAgent3D
@export var PROGRESSION_AREA: Area3D 
@export var HURT_PARTICLE_SCENE: PackedScene
@export var DEATH_PARTICLE_SCENE: PackedScene
@export var BODY_MATERIAL: ShaderMaterial
@export var DAMAGE_NUMBER: PackedScene

var health = MAX_HEALTH
var target_direction = Vector3.ZERO

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
	if $Audio: $Audio.play_2d_sound(["hit_1", "hit_2", "hit_3"], .8)
	Particles.spawn(_position, HURT_PARTICLE_SCENE)
	if health <= 0:
		PROGRESSION_AREA.monitoring = true
		ANIM.play("DEATH",0,1,false)
		Save.data["wrath_defeated"] = true
		Save.save_game()	

func shake_camera() -> void:
	Shake.tremor(3)

func _on_trigger_area_body_entered(body: Node) -> void:
	if not body.is_in_group(TARGET.TARGET_GROUP): return
	if not ANIM.is_playing(): ANIM.play("INTRO")
	
func _ready() -> void:
	health = MAX_HEALTH
	target_direction = -global_transform.basis.z.normalized()
	if Save.data.has("wrath_defeated") and Save.data["wrath_defeated"]:
		queue_free()
		PROGRESSION_AREA.monitoring = true

func _physics_process(delta: float) -> void:
	
	if not ANIM.is_playing(): return
	if health > 0: 
		move_and_slide()
	else:
		velocity = Vector3(0, 0, 0)
		return
	if not is_on_floor(): velocity += get_gravity() * delta
	track_towards_direction(delta)
	target_direction = (TARGET.global_transform.origin - global_transform.origin).normalized()

	if ANIM.current_animation == "CHASE":
		TARGET.move_to_target(delta, self, SPEED)
		ANIM.play_random_attack(global_position, TARGET.global_position,delta)
		
