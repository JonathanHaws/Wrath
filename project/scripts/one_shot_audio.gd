extends Node

@export var SOUNDS: Array[AudioStream] = []

func play_2d_sound(sound: Variant, pitch_min: float = 1.0, pitch_max: float = 1.0, volume_min: float = 0.0, volume_max: float = 0.0) -> AudioStreamPlayer2D:
	
	if sound is Array:
		if sound.size() == 0: return
		var random_index = randi() % sound.size()
		
		if sound[0] is AudioStream:
			sound = sound[random_index]
		elif sound[0] is String:
			var sound_name = sound[random_index]
			for s in SOUNDS:
				if s.resource_path.get_file().get_basename().to_lower() == sound_name.to_lower():
					sound = s
					break
	
	if sound == null or not (sound is AudioStream):
		return null
	
	var player = AudioStreamPlayer2D.new()
	player.stream = sound
	player.pitch_scale = randf_range(pitch_min, pitch_max)
	player.volume_db = randf_range(volume_min, volume_max)
	player.bus = "SFX"
	player.attenuation = 0
	player.connect("tree_entered", Callable(player, "play"))
	player.connect("finished", Callable(player, "queue_free"))
	get_tree().root.call_deferred("add_child", player)
	return player
