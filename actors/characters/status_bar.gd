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
var difference_delay := 0.0
var difference_value: float = 0.0

func update_bar(delta := 0.0) -> void:
	if not tracked_node: return

	# Update max and min first to avoid flicker
	max_value = tracked_node.get(tracked_max_property)
	difference_bar.max_value = max_value
	difference_bar.min_value = min_value
	if pixel_expansion_rate > 0:
		size.x = default_width + max(0, (max_value - default_max_value) * pixel_expansion_rate)

	value = tracked_node.get(tracked_property)

	if value > difference_bar.value: # Increasing first to work in ready
		difference_bar.value = value
	
	if (value < difference_bar.value) and (difference_delay <= 0): # Decreasing
		difference_delay = difference_speed
		difference_value = value
		
	if (difference_value != value): # Combo Hits Decreasing... Reset timer each hit
		difference_delay = difference_speed
		difference_value = value
	
	if difference_delay > 0.0:
		difference_delay -= delta
		if difference_delay <= 0.0:
			difference_bar.value = value

func _ready()-> void:
	default_width = size.x
	default_max_value = max_value

	difference_bar.value = 0.0 # give hitbox nodes a chance to load in save and persistent data 
	await get_tree().process_frame
	await get_tree().physics_frame
	update_bar()
	

func _process(_delta)-> void:
	update_bar(_delta)
