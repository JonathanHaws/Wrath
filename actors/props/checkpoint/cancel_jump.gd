extends Node
@export var PLAYER_GROUP = "player"
@export var AREA: Area3D
@export var JUMP_MULTIPLIER: float = 1.0
var original_jump_multiplier: float = 1.0

func _ready() -> void:
	AREA.body_entered.connect(_on_enter)
	AREA.body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if body.is_in_group(PLAYER_GROUP):
		original_jump_multiplier = body.JUMP_MULTIPLIER
		body.JUMP_MULTIPLIER = JUMP_MULTIPLIER

func _on_exit(body: Node) -> void:
	if body.is_in_group(PLAYER_GROUP):
		body.JUMP_MULTIPLIER = original_jump_multiplier
