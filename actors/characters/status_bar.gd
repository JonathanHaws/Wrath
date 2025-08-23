extends ProgressBar
@export var difference_speed: float = 0.5
@export var difference_bar: ProgressBar
@export var expands: bool = false
@export var tracked_node: Node
@export var tracked_property: String = "HEALTH"
@export var tracked_max_property: String = "MAX_HEALTH"
@export var pixel_expansion_rate: float = 0.0
var default_width 
var default_max_value
var timer

func _on_timer_timeout() -> void:
	difference_bar.value = value

func change_value(_new_value: float) -> void:
	if value == _new_value: return
	if timer:
		timer.stop()
		timer.start()
	if _new_value >= value:
		difference_bar.value = value
	if difference_speed == 0:
		difference_bar.value = _new_value
	value = _new_value

func _ready()-> void:
	if difference_speed > 0:
		timer = Timer.new()
		timer.wait_time = difference_speed
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_on_timer_timeout"))
		add_child(timer)

	default_width = size.x
	default_max_value = max_value
	difference_bar.value = value
	
	if max_value != tracked_node.get(tracked_max_property):
		max_value = tracked_node.get(tracked_max_property)
		difference_bar.max_value = max_value
		difference_bar.min_value = min_value
		size.x = default_width + max(0, (max_value - default_max_value) * pixel_expansion_rate)

	if tracked_property in tracked_node:
		value = tracked_node.get(tracked_property)
		difference_bar.value  = value
	
func _process(_delta)-> void:
	
	if tracked_node:
		
		if tracked_max_property in tracked_node: # Update max value first so health doesn't have 1 frame flicker
			if max_value != tracked_node.get(tracked_max_property):
				max_value = tracked_node.get(tracked_max_property)
				difference_bar.max_value = max_value
				difference_bar.min_value = min_value
				size.x = default_width + max(0, (max_value - default_max_value) * pixel_expansion_rate)
		
		if tracked_property in tracked_node:
			change_value(tracked_node.get(tracked_property))
