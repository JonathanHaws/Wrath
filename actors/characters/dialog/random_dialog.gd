extends Timer
@export var DIALOG: Node ## Calls play fork for each line
@export var FORKS: Array[String] = [] ## Lines to periodically play
@export var MIN_INTERVAL: float = 5.0 ## Minimum seconds between lines
@export var MAX_INTERVAL: float = 15.0 ## Maximum seconds between lines
@export var DELETE_AFTER_PLAY: bool = false ## Remove line from list after playing
@export var SHUFFLE_AT_START: bool = false  
@export var SHUFFLE_EACH_PLAY: bool = false 
var index: int = 0

func _on_timeout() -> void:
	if FORKS.size() == 0 or not DIALOG: return
	DIALOG.play_fork(FORKS[index])
	
	if DELETE_AFTER_PLAY:
		FORKS.remove_at(index)
		if FORKS.size() == 0:
			stop()
			return
	
	index = (index + 1) % FORKS.size()
	_set_random_wait()
	start()

func _set_random_wait() -> void:
	wait_time = randf_range(MIN_INTERVAL, MAX_INTERVAL)
	
func _ready() -> void:
	index = randi() % FORKS.size()
	_set_random_wait()
	connect("timeout", Callable(self, "_on_timeout"))
