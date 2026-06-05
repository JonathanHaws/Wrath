extends Node
@export var HITSHAPE: Area3D
@export var HEAL_RATE: float = 1.0 ## HP per second
@export var HEAL_DELAY: float = 6.0 ## Seconds after damage before regen starts
@export var HEAL_RATE_KEY: String = "auto_heal_rate"
@export var HEAL_DELAY_KEY: String = "auto_heal_delay"
var time_since_damage: float = 0.0

func _on_hurt(_damage = null) -> void:
	time_since_damage = 0.0

func load_heal_data() -> void:
	HEAL_RATE = Save.data.get(HEAL_RATE_KEY, HEAL_RATE)
	HEAL_DELAY = Save.data.get(HEAL_DELAY_KEY, HEAL_DELAY)

func _ready() -> void:
	load_heal_data()
	Save.connect("save_data_updated", load_heal_data)
	if HITSHAPE and HITSHAPE.has_signal("HURT"):
		HITSHAPE.HURT.connect(_on_hurt)

func _process(delta: float) -> void:
	#print("Heal Rate: ", HEAL_RATE, ", Heal Delay ", HEAL_DELAY)
	
	if not HITSHAPE: return
	if not "HEALTH" in HITSHAPE: return
	if not "MAX_HEALTH" in HITSHAPE: return

	time_since_damage += delta
	if time_since_damage < HEAL_DELAY: return

	HITSHAPE.HEALTH += HEAL_RATE * delta

	if HITSHAPE.HEALTH > HITSHAPE.MAX_HEALTH:
		HITSHAPE.HEALTH = HITSHAPE.MAX_HEALTH
