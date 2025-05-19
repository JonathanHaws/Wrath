extends CharacterBody3D
@export var MAX_HEALTH: int = 4000
@export var SPEED = 9.0
@export var TARGET: Node3D
@export var ANIM: AnimationPlayer
@export var MESH_ANIM: AnimationPlayer
@export var MESH: Node3D
@export var PROGRESSION_AREA: Area3D 
@export var HURT_PARTICLE_SCENE: PackedScene
@export var DEATH_PARTICLE_SCENE: PackedScene
@export var BODY_MATERIAL: ShaderMaterial
@export var DAMAGE_NUMBER: PackedScene
@export var SAVE_KEY_ENCOUNTERED: String = "wrath_encountered"
@export var SAVE_KEY_DEFEATED: String = "wrath_defeated"
var health = MAX_HEALTH

func hurt(_damage: float = 0, _group: String = "", _position: Vector3 = Vector3.ZERO) -> void:
	WorldUI.show_symbol(global_position, DAMAGE_NUMBER, 140.0, "Node2D/Label", _damage)
	SlowMotion.impact(.04)
	Shake.tremor(2)
	if $Audio: $Audio.play_2d_sound(["hit_1", "hit_2", "hit_3"], .8)
	Particles.spawn(_position, HURT_PARTICLE_SCENE)
	if health <= 0:
		if PROGRESSION_AREA: PROGRESSION_AREA.monitoring = true
		ANIM.play("DEATH",0,1,false)
		Save.data[SAVE_KEY_DEFEATED] = true
		Save.save_game()	

func _on_trigger_area_body_entered(body: Node) -> void:
	if not body.is_in_group(TARGET.TARGET_GROUP): return
	if not ANIM.is_playing(): ANIM.play("INTRO")
	Save.data[SAVE_KEY_ENCOUNTERED] = true
	Save.save_game()	

func _unlock_progression()-> void:
	queue_free()
	if PROGRESSION_AREA: PROGRESSION_AREA.monitoring = true
	
func _ready() -> void:
	health = MAX_HEALTH
	if Save.data.has(SAVE_KEY_DEFEATED) and Save.data[SAVE_KEY_DEFEATED]:
		_unlock_progression()

func _physics_process(delta: float) -> void:
	if health > 0: move_and_slide()
	if not ANIM.is_playing(): return
	if not is_on_floor(): velocity += get_gravity() * delta
	TARGET.track(delta)
	ANIM.play_random_attack(global_position, TARGET.global_position,delta)
		
