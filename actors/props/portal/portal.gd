extends Node3D
@export var AREA: Area3D
@export var ANIM: AnimationPlayer
@export var REAPER: CharacterBody3D
@export var PLAYER_SPOT: Node3D

func _play_end_cutscene()-> void:
	if REAPER and REAPER.ANIM:
		REAPER.ANIM.play("ESCAPE")
	
func _on_body_entered(body: Node) -> void:
	if not body == REAPER: return
	if (ANIM):	
		REAPER.IN_CUTSCENE = true
		ANIM.play("ESCAPE")
	
func _teleport_player_to_cutscene_spot() -> void:
	REAPER.global_transform.origin = PLAYER_SPOT.global_transform.origin
	REAPER.global_transform = PLAYER_SPOT.global_transform
	REAPER.global_transform = PLAYER_SPOT.global_transform
	REAPER.MESH.transform = Transform3D.IDENTITY
	REAPER.MESH_ANIM.playback_default_blend_time = 0
	
func _ready() -> void:
	
	if Save.data.has("wrath_defeated") and Save.data["wrath_defeated"]:
		AREA.monitoring = true

	AREA.connect("body_entered", Callable(self, "_on_body_entered"))
