extends ProgressBar
@export var difference_speed: float = 0.5
@export var expands: bool = false
@export var tracked_node: Node
@export var tracked_property: String = "HEALTH"
@export var tracked_max_property: String = "MAX_HEALTH"
@export var expand_min_value: float = 0.0
@export var pixel_expansion_rate: float = 0.0
var default_width 

func _on_timer_timeout() -> void:
	$Change.value = value

func _on_value_changed(_new_value: float) -> void:
	$Change.max_value = max_value
	$Change.min_value = min_value
	$Timer.stop()
	$Timer.start()
	if difference_speed == 0 or _new_value > value:
		$Change.value = value
	
func _ready()-> void:
	value = 0
	default_width = size.x
	if difference_speed > 0: $Timer.wait_time = difference_speed
	_on_value_changed(value)

func _process(_delta)-> void:

	if tracked_node:
		
		if tracked_property in tracked_node:
			value = tracked_node.get(tracked_property)
			
		
		if tracked_max_property in tracked_node:
			max_value = tracked_node.get(tracked_max_property)
			size.x = default_width + max(0, (max_value - expand_min_value) * pixel_expansion_rate)
			
