extends ProgressBar
@export var difference_speed: float = 0.5
@export var expands: bool = false
@export var BAR_PIXEL_WIDTH: float = 8.0
@export var save_key_max_value: String = "" #example max_health
@export var save_key_value: String = ""
var old_max_value = max_value

func _on_timer_timeout() -> void:
	$Change.value = value

func _on_value_changed(_new_value: float) -> void:
	$Change.max_value = max_value
	$Change.min_value = min_value
	$Timer.stop()
	$Timer.start()
	if difference_speed == 0:
		$Change.value = value
	
func _ready()-> void:
	
	if save_key_max_value != "":
		if Save.data.has(save_key_max_value):
			if not expands: return
			max_value = Save.data[save_key_max_value]
			value = max_value
			
	if save_key_value != "" and Save.data.has(save_key_value):
		value = Save.data[save_key_value]		
		$Change.value = value	

	if difference_speed > 0: $Timer.wait_time = difference_speed
	_on_value_changed(value)

func _process(_delta)-> void:

	if max_value != old_max_value:
		if not expands: return
		size.x = max_value * BAR_PIXEL_WIDTH
		old_max_value = max_value
