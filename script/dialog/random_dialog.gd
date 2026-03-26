extends Timer
@export var DIALOG: Node ## Calls play branch for each line
@export var HIT_SHAPE: Node ## Specifies the node that has 'HEALTH' and 'MAX HEALTH' For trigger hps
@export var SEQUENTIAL: bool = false
@export var DELETE_AFTER_PLAY: bool = true ## Remove line from list after playing
@export var MIN_INTERVAL: float = 4.5 ## Minimum seconds between lines
@export var MAX_INTERVAL: float = 8.0 ## Maximum seconds between lines
@export var FAIL_INTERVAL: float = 0.2 ## Timeout if no line can play
@export var LINES: Array[String] = [] ## Specifies which dialog branch to go to 
var index: int = 0
## Potential cool feature is save dialog so it only ever happens once


func get_branch_time(start_index: int) -> float:
	var total: float = 0.0
	var i: int = start_index
	while i < DIALOG.dialog.size() and not DIALOG.dialog[i].has("branch"):
		if DIALOG.dialog[i].has("say_timed"):
			total += float(DIALOG.dialog[i].say_timed["for"])
		i += 1
	return total

func is_hp_in_range(entry: Dictionary) -> bool:
	var min_hp: float = 0.0
	var max_hp: float = 1.0
	if entry.has("min_health"): min_hp = entry["min_health"]
	if entry.has("max_health"): max_hp = entry["max_health"]
	var current_hp: float = 1.0
	if HIT_SHAPE: current_hp = HIT_SHAPE.HEALTH / HIT_SHAPE.MAX_HEALTH
	return current_hp >= min_hp and current_hp <= max_hp

func _on_timeout() -> void:
	#print('attempting to spawn random dialog')
	if not DIALOG: return
	if LINES.size() == 0: stop(); return
	wait_time = FAIL_INTERVAL
	start()
	
	var entry: Dictionary = DIALOG.get_dictionary_for_value(LINES[index], 1)	
	if not is_hp_in_range(entry): return
	DIALOG.spawn_branch(LINES[index])		
	#print(entry)
	
	var branch_time = get_branch_time(DIALOG.index)
	_set_random_wait(branch_time)

	if DELETE_AFTER_PLAY: if index < LINES.size(): LINES.remove_at(index)
	if LINES.size() > 0:# Deletion shifts array so no +1 is needed for sequential incrementation
		if SEQUENTIAL: index = index % LINES.size() 
		else: index = (index + randi_range(1, LINES.size())) % LINES.size()

func _set_random_wait(extra: float = 0.0) -> void:
	wait_time += randf_range(MIN_INTERVAL, MAX_INTERVAL) + extra
	start()
	
func _ready() -> void:
	_set_random_wait()
	stop()
	if not SEQUENTIAL: index = randi() % LINES.size()
	connect("timeout", Callable(self, "_on_timeout"))
