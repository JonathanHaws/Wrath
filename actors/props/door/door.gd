extends Node3D
@export var PLAYER_GROUP = "player"
@export var MESH: Node
@export var AREA: Area3D
@export var ANIM: AnimationPlayer
@export var START: Node3D
@export var DESTINATION_NODE_NAME: String 
## Has to be string not packed scene to avoid circular dependency infinite recursion serialization issues.
## But export file will update automatically if reorganizing folders / files in godot editor
@export_file("*.tscn") var DESTINATION_SCENE: String 
var REAPER

func _freeze_player(freeze: float) -> void:
	REAPER.SPEED_MULTIPLIER = freeze
	REAPER.TURN_MULTIPLIER = freeze

func _load_new_scene() -> void:
	Save.data["door_node_name"] = DESTINATION_NODE_NAME
	Save.save_game()
	
	if DESTINATION_SCENE != "":
		get_tree().change_scene_to_file(DESTINATION_SCENE)

func _on_area_body_entered(body: Node) -> void:
	if PLAYER_GROUP != "" and not body.is_in_group(PLAYER_GROUP): return
	REAPER = body
	if not DESTINATION_SCENE: return
	if ANIM: ANIM.play("DOOR")

func _ready() -> void:
	AREA.connect("body_entered", Callable(self, "_on_area_body_entered"))
