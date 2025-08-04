extends CharacterBody3D
@export var TARGET: Node3D
@export var ANIM: AnimationPlayer
@export var SAVE_KEY_ENCOUNTERED: String = "wrath_encountered"
@export var HEALTH: int = 100
@export var MAX_HEALTH: int = 100

func _on_trigger_area_body_entered(body: Node) -> void:
	if not body.is_in_group(TARGET.TARGET_GROUP): return
	if not ANIM.is_playing(): ANIM.play("INTRO")
	Save.data[SAVE_KEY_ENCOUNTERED] = true
	Save.save_game()	

	
		
