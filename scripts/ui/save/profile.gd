extends Button

func format_time(total_seconds: float) -> String:
	var total_seconds_int = int(total_seconds)
	var milliseconds = int(fmod(total_seconds, 1) * 10) 
	var time_parts = []
	if total_seconds_int >= 86400: time_parts.append(str(total_seconds_int / 86400.0))
	if total_seconds_int >= 3600: time_parts.append("%02d" % ((total_seconds_int % 86400) / 3600.0))
	if total_seconds_int >= 60: time_parts.append("%02d" % ((total_seconds_int % 3600) / 60.0))
	time_parts.append("%02d.%d" % [total_seconds_int % 60, milliseconds])
	return ":".join(time_parts)
	
func format_profile(data: Dictionary) -> void:
	#print(data)
	if "play_time" in data:
		text = data["file_name"].split(".")[0] + " " + format_time(data["play_time"])
	else:
		text = data["file_name"].split(".")[0]
	
