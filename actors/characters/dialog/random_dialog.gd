extends Timer
@export var SEQUENTIAL: bool = false
@export var MIN_INTERVAL: float = 1.0 ## Minimum seconds between lines
@export var MAX_INTERVAL: float = 3.0 ## Maximum seconds between lines
@export var FAIL_INTERVAL: float = 1.0 ## Timeout if no line can play
@export var DELETE_AFTER_PLAY: bool = false ## Remove line from list after playing
@export var DIALOG: Node ## Calls play fork for each line
@export var HIT_SHAPE: Node ## Specifies the node that has 'HEALTH' and 'MAX HEALTH' For trigger hps
@export var LINES: Array[String] = [] ## Specifies which dialog fork to go to 
@export var LINE_TIMES: Array[float] = [] ## Specifies how much time each will add to timeout on top of MIN / Max Interval
@export var TRIGGER_MIN_HP: Array[float] = [] ## Specifies the min hitbox health this line can be spawned in
@export var TRIGGER_MAX_HP: Array[float] = [] ## Specifies the max hitbox health this line can be spawned in
var index: int = 0

func _on_timeout() -> void:
	if LINES.size() == 0 or not DIALOG: return
	
	var min_hp: float = 0.0
	var max_hp: float = 1.0
	if index < TRIGGER_MIN_HP.size(): min_hp = TRIGGER_MIN_HP[index]
	if index < TRIGGER_MAX_HP.size(): max_hp = TRIGGER_MAX_HP[index]
	
	var current_hp: float = 1.0
	if HIT_SHAPE: current_hp = HIT_SHAPE.HEALTH / HIT_SHAPE.MAX_HEALTH
	
	if current_hp >= min_hp and current_hp <= max_hp:
		DIALOG.play_fork(LINES[index])
	
		if DELETE_AFTER_PLAY:
			if index < LINES.size(): LINES.remove_at(index)
			if index < LINE_TIMES.size(): LINE_TIMES.remove_at(index)
			if index < TRIGGER_MIN_HP.size(): TRIGGER_MIN_HP.remove_at(index)
			if index < TRIGGER_MAX_HP.size(): TRIGGER_MAX_HP.remove_at(index)
			if LINES.size() == 0: return

		_set_random_wait()
		start()
	
	else:
		wait_time = FAIL_INTERVAL
		start()
		
	if SEQUENTIAL:
		index = (index + 1) % LINES.size()
	else:
		index = (index + randi_range(1, LINES.size())) % LINES.size()

func _set_random_wait() -> void:
	var extra : float = 0.0
	if index < LINE_TIMES.size(): extra = LINE_TIMES[index]
	wait_time = randf_range(MIN_INTERVAL, MAX_INTERVAL) + extra
	
func _ready() -> void:
	index = randi() % LINES.size()
	_set_random_wait()
	connect("timeout", Callable(self, "_on_timeout"))
