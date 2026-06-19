extends Node ## script for trophies / acheivements
## uses godotsteam addon / extension (Not godotsteam_server) set app id and startup in settings

#func _ready() -> void:
	#var steam_running = Steam.isSteamRunning()
	#if !steam_running: print("Steam initialization failed!")
	#print("Steam initialization success!")

#func _process(delta: float) -> void:
	#if not OS.is_debug_build(): return
	#if Input.is_key_pressed(KEY_T): # just for clearing trophies for testing
		#Steam.clearAchievement("LUST_TROPHY")
		#Steam.clearAchievement("GLUTTONY_TROPHY")
		#Steam.clearAchievement("GREED_TROPHY")
		#Steam.clearAchievement("SLOTH_TROPHY")
		#Steam.clearAchievement("WRATH_TROPHY")
		#Steam.clearAchievement("ENVY_TROPHY")
		#Steam.clearAchievement("PRIDE_TROPHY")

func set_achievement(trophy: String) -> void:
	var status: Dictionary = Steam.getAchievement(trophy)
	if not status.get("achieved", false):
		Steam.setAchievement(trophy)
		Steam.storeStats()
