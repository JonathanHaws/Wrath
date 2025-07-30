extends CharacterBody3D
@export var HURT_PARTICLE_SCENE: PackedScene
@export var HEALTH = 500
@export var MAX_HEALTH = 500

@export var SAVE_KEY_PLAYER_DEATHS: String = "deaths"
@export var RESPAWN: bool = false

func get_save_key(suffix: String) -> String:
	var scene_path = get_tree().current_scene.scene_file_path
	var node_path = get_path()
	return "%s|%s_%s" % [scene_path, node_path, suffix]

func teleport_children_to_self() -> void:
	for child in get_children():
		if child.is_in_group("teleport_to_attacking_body"):
			child.global_position = global_position

func _ready()-> void:
	
	#if Save.data.has(get_save_key("max_health")):
		#MAX_HEALTH = Save.data[get_save_key("max_health")]
		
	if Save.data.has(get_save_key("health")):
		HEALTH = Save.data[get_save_key("health")]

	if RESPAWN and Save.data.has(SAVE_KEY_PLAYER_DEATHS):	
		if Save.data.has(get_save_key("respawn_at_deathcount")):
			if int(Save.data[get_save_key("respawn_at_deathcount")]) <= int(Save.data[SAVE_KEY_PLAYER_DEATHS]):
				Save.data[get_save_key("respawn_at_deathcount")] = int(Save.data[SAVE_KEY_PLAYER_DEATHS]) + 1
				HEALTH = MAX_HEALTH
				Save.data[get_save_key("health")] = HEALTH
			 			
	if HEALTH < 0:
		queue_free()
		
	Save.save_game()
			
func _exit_tree() -> void:
	if HEALTH == MAX_HEALTH:
		if Save.data.has(get_save_key("health")):
			Save.data.erase(Save.data[get_save_key("health")])
	else:
		Save.data[get_save_key("health")] = HEALTH

	if HEALTH <= 0:
		Save.data[get_save_key("respawn_at_deathcount")] = int(Save.data[SAVE_KEY_PLAYER_DEATHS]) + 1
	Save.save_game()

		
