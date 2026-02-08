extends CharacterBody3D
@export var TARGET: Node3D
@export var ANIM: AnimationPlayer
@export var SAVE_KEY_ENCOUNTERED: String = "wrath_encountered"
@export var DOOR_TO_UNLOCK_GROUP: String = ""
@export var DEFEATED_KEY: String = ""

func defeated() -> void:
	if DEFEATED_KEY != "":
		Save.data[DEFEATED_KEY] = true
		Save.save_game()
	for door in get_tree().get_nodes_in_group(DOOR_TO_UNLOCK_GROUP):
		if "LOCKED" in door: door.LOCKED = false

func _on_trigger_area_body_entered(body: Node) -> void:
	if not body.is_in_group(TARGET.TARGET_GROUP): return
	if not ANIM.is_playing(): ANIM.play("INTRO")
	Save.data[SAVE_KEY_ENCOUNTERED] = true
	Save.save_game()	
	
func _ready() -> void:
	if DEFEATED_KEY != "" and Save.data.has(DEFEATED_KEY):
		queue_free()

func _test() -> void:
	print('test')
		
func _process(_delta: float) -> void:
	pass
	#print(ANIM.is_playing(), " ", ANIM.current_animation)
