extends Node3D
@export var PLAYER_GROUP = "player"

func _play_if_not_playing() -> void:
	if $AnimationPlayer.is_playing(): return
	if $AnimationPlayer.speed_scale == 1.0:
		$AnimationPlayer.play("fall", 0, 1, true)
	else:
		$AnimationPlayer.play("fall", 0, 1, false)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group(PLAYER_GROUP): return
	_play_if_not_playing()
	$AnimationPlayer.speed_scale = 1.0

func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body.is_in_group(PLAYER_GROUP): return
	_play_if_not_playing()
	$AnimationPlayer.speed_scale = -1.0
 	
func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_3d_body_entered)
	$Area3D.body_exited.connect(_on_area_3d_body_exited)
	$AnimationPlayer.speed_scale = 0
	$AnimationPlayer.play()
