extends ProgressBar

@export var host: Node
@export var property_name: String = "health"
@export var max_property_name: String = "health"

func _on_timer_timeout() -> void:
	$Change.value = value

func _on_value_changed(value: float) -> void:
	$Change.max_value = max_value
	$Change.min_value = min_value
	$Timer.stop()
	$Timer.start()
	
func _ready()-> void:
	value = host.get(property_name)
	max_value = host.get(max_property_name)
	_on_value_changed(value)
	
func _process(_delta: float) -> void:
	if host: value = host.get(property_name)
