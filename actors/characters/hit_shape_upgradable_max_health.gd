extends Node
@export var HIT_SHAPE: Node
@export var MAX_HEALTH_KEY: String = ""
@export var ANIMATION_PLAYER: AnimationPlayer
@export var UPGRADE_ANIMATION: String

func _check_max_health() -> void:
	var difference = Save.data[MAX_HEALTH_KEY] - HIT_SHAPE.MAX_HEALTH
	
	if difference <= 0: return
	
	if ANIMATION_PLAYER and UPGRADE_ANIMATION != "":
		ANIMATION_PLAYER.play(UPGRADE_ANIMATION)
	
	HIT_SHAPE.MAX_HEALTH = Save.data[MAX_HEALTH_KEY]

func _ready() -> void:
	if MAX_HEALTH_KEY.is_empty(): MAX_HEALTH_KEY = Save.get_unique_key(self, "max_health")
	
	if not Save.data.has(MAX_HEALTH_KEY):
		Save.data[MAX_HEALTH_KEY] = HIT_SHAPE.MAX_HEALTH
	
	HIT_SHAPE.MAX_HEALTH = Save.data[MAX_HEALTH_KEY]
	
	Save.connect("save_data_updated", Callable(self, "_check_max_health"))
