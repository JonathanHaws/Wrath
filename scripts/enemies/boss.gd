extends CharacterBody3D
@export var TARGET: Node3D
@export var ANIM: AnimationPlayer
@export var PROGRESSION_AREA: Area3D 
@export var HURT_PARTICLE_SCENE: PackedScene
@export var DAMAGE_NUMBER: PackedScene
@export var SAVE_KEY_ENCOUNTERED: String = "wrath_encountered"
@export var SAVE_KEY_DEFEATED: String = "wrath_defeated"
@export var HEALTH: int = 100
@export var MAX_HEALTH: int = 100

func _on_trigger_area_body_entered(body: Node) -> void:
	if not body.is_in_group(TARGET.TARGET_GROUP): return
	if not ANIM.is_playing(): ANIM.play("INTRO")
	Save.data[SAVE_KEY_ENCOUNTERED] = true
	Save.save_game()	

func _unlock_progression(enable: bool = true) -> void:
	if PROGRESSION_AREA: PROGRESSION_AREA.monitoring = enable
	if enable: queue_free()
	if enable:
		Save.data[SAVE_KEY_DEFEATED] = true
		Save.save_game()	
	
func _ready() -> void:
	_unlock_progression(Save.data.has(SAVE_KEY_DEFEATED) and Save.data[SAVE_KEY_DEFEATED])
	
		
