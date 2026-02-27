extends Button

func format_time(total_seconds: float) -> String:
	var total_seconds_int = int(total_seconds)
	var days = total_seconds_int / 86400.0
	var hours = (total_seconds_int % 86400) / 3600.0
	var minutes = (total_seconds_int % 3600) / 60.0

	var parts = []
	if days >= 1:
		var label = "day"
		if days > 1: label += "s"
		parts.append("%d %s" % [int(days), label])
	if hours >= 1:
		var label = "hour"
		if hours > 1: label += "s"
		parts.append("%d %s" % [int(hours), label])
	if minutes >= 0:
		var label = "min"
		if minutes > 1: label += "s"
		parts.append("%d %s" % [int(minutes), label])
	if parts.size() == 0:
		parts.append("0 mins")
	return " ".join(parts)

func get_formatted_last_played(file_name: String) -> String:
	if file_name == "":
		return ""
	var file_path = "user://" + file_name
	var modified_time = FileAccess.get_modified_time(file_path)
	if modified_time == 0:
		return ""
	var dt = Time.get_date_dict_from_unix_time(modified_time)
	#print(dt)
	
	var month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var month_name = month_names[dt.month - 1]
	return "%d %s %d" % [dt.day, month_name, dt.year]
	
func format_profile(data: Dictionary) -> void:
	#print(data)
	text += data["file_name"].split(".")[0] + "\n" 
	
	text += get_formatted_last_played(data.get("file_name")) + " "
	
	if "play_time" in data:
		text += format_time(data["play_time"])

func _ready() -> void:
	call_deferred("grab_focus")
	
