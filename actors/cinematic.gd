extends Node
@export var AREA: Area3D
@export var ANIM: AnimationPlayer
@export var ANIM_NAME: String = ""
@export var PLAYER_BODY_GROUP = "player"
@export var PLAYER_SPOT: Node3D
@export var ANIMATION_PLAYER_GROUPS: Array[String]
@export var ANIMATION_NAMES: Array[String]
var last_player_body : Node = null

func play_animations_in_other_nodes() -> void:
	for i in range(ANIMATION_PLAYER_GROUPS.size()):
		if i >= ANIMATION_NAMES.size(): continue
		for node in get_tree().get_nodes_in_group(ANIMATION_PLAYER_GROUPS[i]):
			if node is AnimationPlayer and node.has_animation(ANIMATION_NAMES[i]):
				node.play(ANIMATION_NAMES[i])
			
func _on_body_entered(body: Node) -> void:
	if PLAYER_BODY_GROUP != "" and not body.is_in_group(PLAYER_BODY_GROUP): return
	last_player_body = body
		
	play_animations_in_other_nodes()
				
	if ANIM and ANIM.has_animation(ANIM_NAME): ANIM.play(ANIM_NAME)
	
func _teleport_player_to_player_spot() -> void:
	if not last_player_body or not PLAYER_SPOT: return
	last_player_body.global_transform.origin = PLAYER_SPOT.global_transform.origin
	last_player_body.global_transform = PLAYER_SPOT.global_transform
	last_player_body.global_transform = PLAYER_SPOT.global_transform
	last_player_body.MESH.transform = Transform3D.IDENTITY
	last_player_body.MESH_ANIM.playback_default_blend_time = 0
	
func _ready() -> void:
	
	if AREA: AREA.body_entered.connect(_on_body_entered)
