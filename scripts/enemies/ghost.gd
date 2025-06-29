extends CharacterBody3D
@export var HURT_PARTICLE_SCENE: PackedScene
@export var DAMAGE_NUMBER: PackedScene
@export var HEALTH = 500
@export var MAX_HEALTH = 500

@export var SAVE_KEY_PLAYER_DEATHS: String = "deaths"
@export var RESPAWN: bool = false

func get_save_key(suffix: String) -> String:
	var scene_path = get_tree().current_scene.scene_file_path
	var node_path = get_path()
	return "%s|%s_%s" % [scene_path, node_path, suffix]

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
	Save.save_game()

func hurt(_damage: float = 0, _group: String = "", _position: Vector3 = Vector3.ZERO) -> void:
	WorldUI.show_symbol(global_position, DAMAGE_NUMBER, 140.0, "Node2D/Label", _damage)
	SlowMotion.impact(.04)
	Shake.tremor(2)
	if $Audio: $Audio.play_2d_sound(["hit_1", "hit_2", "hit_3"], .8)
	Particles.spawn(HURT_PARTICLE_SCENE, _position)
	if HEALTH <= 0:
		queue_free()
		
