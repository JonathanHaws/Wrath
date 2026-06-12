extends Label
func _ready() -> void:
	visibility_changed.connect(build_text)
	text = build_text()

func build_text() -> String:
	var save_name: String = Save.game_file_name.trim_suffix(".json")
	var deaths: int = int(Save.data.get("deaths", 0))
	var play_time: float = Save.data.get("play_time", 0.0)
	var ng: int = int(Save.data.get("new_game_count", 0))
	var line: String = save_name + "\n" \
		+ "NEW GAME +" + str(ng) + "\n" \
		+ "PLAY TIME - " + format_time(play_time) + "\n"
	if Save.data.has("completion_time"): line += "COMPLETION TIME - " + format_time(Save.data["completion_time"]) + "\n"
	else: line += "COMPLETION TIME - X\n"
	line += "DEATHS - " + str(deaths)
	line = line.to_upper()
	text = line
	return line

func format_time(seconds: float) -> String:
	var total: int = int(seconds)
	var hours: float = float(total) / 3600.0
	var minutes: float = float(total % 3600) / 60.0
	var secs: float = float(total % 60)
	return "%02d:%02d:%02d" % [int(hours), int(minutes), int(secs)]
