extends Node3D
@export var PLAYER_GROUP = "player"
@export var MESH: Node
@export var AREA: Area3D
@export var ANIM: AnimationPlayer
@export var START: Node3D
@export var DESTINATION_NODE_NAME: String 
@export var DESTINATION_SCENE: String
#has to be string not packed scene to avoid circular dependency infinite recursion serialization issues 
var REAPER

func _freeze_player(freeze: float) -> void:
	REAPER.SPEED_MULTIPLIER = freeze
	REAPER.TURN_MULTIPLIER = freeze

func _load_new_scene() -> void:
	Save.data["door_node_name"] = DESTINATION_NODE_NAME
	Save.save_game()
	
	if FileAccess.file_exists(DESTINATION_SCENE): # String is a path and file name
		get_tree().change_scene_to_file(DESTINATION_SCENE)
		return
	else: # String is a file name
		#print("Scene Path not found: %s" % DESTINATION_SCENE)
		var stack: Array[String] = ["res://"]

		while stack.size() > 0:
			var current: String = stack.pop_back()
			var dir := DirAccess.open(current)
			if dir == null: continue
			dir.list_dir_begin()
			var file := dir.get_next()
			while file != "":
				if file == "." or file == "..":
					file = dir.get_next()
					continue
				var full_path: String = current.path_join(file)
				if dir.current_is_dir():
					stack.append(full_path)
				elif file.ends_with(".tscn") and file.trim_suffix(".tscn") == DESTINATION_SCENE.get_file().trim_suffix(".tscn"):
					#print("Found file:", full_path)
					get_tree().change_scene_to_file(full_path)
					return
				file = dir.get_next()

func _on_area_body_entered(body: Node) -> void:
	if PLAYER_GROUP != "" and not body.is_in_group(PLAYER_GROUP): return
	REAPER = body
	if not DESTINATION_SCENE: return
	if ANIM: ANIM.play("DOOR")

func _ready() -> void:
	AREA.connect("body_entered", Callable(self, "_on_area_body_entered"))
