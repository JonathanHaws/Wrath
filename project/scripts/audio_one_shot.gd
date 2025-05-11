extends Node

@export var SOUNDS: Array[AudioStream] = []
@export var VOLUME_MULTIPLIERS: Array[float] = []

func play_2d_sound(sound: Variant, volume_multiplier: float = 1.0, pitch: float = 1.0, volume_variance: float = 0.0, pitch_variance: float = 0.0) -> AudioStreamPlayer2D:
	
	var base_volume = 1
	if sound is Array:
		if sound.size() == 0: return
		var random_index = randi() % sound.size()
		
		if sound[0] is AudioStream:
			sound = sound[random_index]
		elif sound[0] is String:
			var sound_name = sound[random_index]
			for s in SOUNDS:
				if s.resource_path.get_file().get_basename().to_lower() == sound_name.to_lower():
					#print(sound_name.to_lower())
					sound = s
					var idx = SOUNDS.find(s)
					if idx < VOLUME_MULTIPLIERS.size():
						base_volume = VOLUME_MULTIPLIERS[idx]
					break
	
	if sound == null or not (sound is AudioStream):
		return null
	
	var player = AudioStreamPlayer2D.new()
	player.stream = sound
	player.pitch_scale = randf_range(pitch - pitch_variance, pitch + pitch_variance)
	#print(base_volume)
	player.volume_db = linear_to_db(base_volume * (volume_multiplier + randf_range(-volume_variance, volume_variance))) 
	player.bus = "SFX"
	player.attenuation = 0
	player.connect("tree_entered", Callable(player, "play"))
	player.connect("finished", Callable(player, "queue_free"))
	get_tree().root.call_deferred("add_child", player)
	return player
