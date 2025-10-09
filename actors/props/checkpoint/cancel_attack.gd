extends Node
@export var PLAYER_GROUP = "player"
@export var AREA: Area3D
@export var ATTACKING_ENABLED: bool = false
var original_attack_state: bool = false

func _ready() -> void:
	AREA.body_entered.connect(_on_enter)
	AREA.body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if body.is_in_group(PLAYER_GROUP):
		original_attack_state = body.ATTACKING_ENABLED
		body.ATTACKING_ENABLED = ATTACKING_ENABLED

func _on_exit(body: Node) -> void:
	if body.is_in_group(PLAYER_GROUP):
		body.ATTACKING_ENABLED = original_attack_state
