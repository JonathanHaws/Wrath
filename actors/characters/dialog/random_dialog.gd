extends Timer
@export var MIN_INTERVAL: float = 1.0 ## Minimum seconds between lines
@export var MAX_INTERVAL: float = 3.0 ## Maximum seconds between lines
@export var FAIL_INTERVAL: float = 1.0 ## Timeout if no line can play
@export var MAX_INDEX_PROGRESSION: int = 1 ## Set to 1 to have lines played sequential... Set to number of lines to have it be random
@export var DELETE_AFTER_PLAY: bool = false ## Remove line from list after playing
@export var DIALOG: Node ## Calls play fork for each line
@export var HIT_SHAPE: Node ## Specifies the node that has 'HEALTH' and 'MAX HEALTH' For trigger hps
@export var LINES: Array[String] = [] ## Specifies which dialog fork to go to 
@export var TRIGGER_HP: Array[float] = [] ## Specifies the max boss health this can be ranomly triggered
@export var LINE_TIMES: Array[float] = [] ## Specifies how much time each will add to timeout on top of MIN / Max Interval
var index: int = 0

func _on_timeout() -> void:
	if LINES.size() == 0 or not DIALOG: return
	
	var trigger_hp : float = 1.0
	if index < TRIGGER_HP.size(): trigger_hp = TRIGGER_HP[index]
	var current_hp: float = 1.0
	if HIT_SHAPE: current_hp = HIT_SHAPE.HEALTH / HIT_SHAPE.MAX_HEALTH
	
	if current_hp <= trigger_hp:
		DIALOG.play_fork(LINES[index])
	
		if DELETE_AFTER_PLAY:
			if index < LINES.size(): LINES.remove_at(index)
			if index < TRIGGER_HP.size(): TRIGGER_HP.remove_at(index)
			if index < LINE_TIMES.size(): LINE_TIMES.remove_at(index)
			if LINES.size() == 0: return

		_set_random_wait()
		start()
	
	else:
		wait_time = FAIL_INTERVAL
		start()
		
	index = (index + randi_range(1, MAX_INDEX_PROGRESSION)) % LINES.size()

func _set_random_wait() -> void:
	var extra : float = 0.0
	if index < LINE_TIMES.size(): extra = LINE_TIMES[index]
	wait_time = randf_range(MIN_INTERVAL, MAX_INTERVAL) + extra
	
func _ready() -> void:
	index = randi() % LINES.size()
	_set_random_wait()
	connect("timeout", Callable(self, "_on_timeout"))
