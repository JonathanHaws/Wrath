extends Node3D
@export var PLAYER_GROUP: String = "player"
@export var ANIM_PLAYER: AnimationPlayer
@export var AREA: Area3D
@export var ASCEND_SPEED: float = 1.0
@export var DESCEND_SPEED: float = 1.0

func _freeze_platform_end():
	if ANIM_PLAYER.speed_scale <= 0: return
	ANIM_PLAYER.speed_scale = 0
	
func _freeze_platform_start():
	if ANIM_PLAYER.speed_scale >= 0: return
	ANIM_PLAYER.speed_scale = 0

func _on_area_entered(body: Node3D) -> void:
	if not body.is_in_group(PLAYER_GROUP): return
	ANIM_PLAYER.play()
	ANIM_PLAYER.speed_scale = DESCEND_SPEED

func _on_area_exited(body: Node3D) -> void:
	if not body.is_in_group(PLAYER_GROUP): return
	ANIM_PLAYER.speed_scale = -ASCEND_SPEED
	ANIM_PLAYER.play("your_animation", -1, -ASCEND_SPEED, true)
 	
func _ready() -> void:
	AREA.body_entered.connect(_on_area_entered)
	AREA.body_exited.connect(_on_area_exited)
	ANIM_PLAYER.speed_scale = 0
	ANIM_PLAYER.play()
