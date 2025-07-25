extends AnimationPlayer

@export var BODY: Node
var last_health: float = INF

func _ready() -> void:
	if BODY and BODY.has_variable("HEALTH"):
		last_health = BODY.HEALTH

func _process(_delta: float) -> void:
	if not BODY or not BODY.has_variable("HEALTH"):
		return

	if BODY.HEALTH < last_health:
		if BODY.HEALTH <= 0:
			play("DEATH")
		else:
			play("HURT")
	last_health = BODY.HEALTH
