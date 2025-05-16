extends AnimationPlayer
@export var area: Area3D
@export var start_index = 0
@export var player_group: String = "player"
@export var dialogue_templates: Array[PackedScene] = []
@export var dialogue_file: Resource
var current_index = start_index
var in_range = false
var next_queued = false
var base_children = 0
var dialogue

func _on_body_entered(body) -> void:
	if not dialogue: return
	if not body.is_in_group(player_group): return
	if is_playing(): queue("entered")
	else: play("entered")
	in_range = true
	_spawn_next_dialogue()

func _on_body_exited(body)-> void:
	if not body.is_in_group(player_group): return
	if is_playing(): queue("exited") 
	else: play("exited")
	in_range = false
	current_index = start_index

func _spawn_next_dialogue() -> void:
	if current_index >= dialogue.size():
		current_index = int(start_index)
		return
	
	if "next" in dialogue[current_index]:
		current_index = int(dialogue[current_index].next)
		if current_index == 0: return
		
	var scene_index = int(dialogue[current_index].scene)
	if scene_index >= 0 and scene_index < dialogue_templates.size():
		if not dialogue_templates[scene_index]: return
		var instance = dialogue_templates[scene_index].instantiate()
		if "info" in dialogue[current_index] and "info" in instance:
			instance.info = dialogue[current_index].info
		add_child(instance)
	
		if not "next" in dialogue[current_index]:
			current_index += 1
		
func _ready():
	base_children = get_child_count()
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

	if dialogue_file:
		var json_as_text = FileAccess.get_file_as_string(dialogue_file.resource_path)
		dialogue = JSON.parse_string(json_as_text) as Array
		#print(dialogue)

func _process(_delta):
	if not in_range: return
	if Input.is_action_just_pressed("interact"): 
		next_queued = true
	if next_queued and  get_child_count() == base_children:
		_spawn_next_dialogue()
		next_queued = false
