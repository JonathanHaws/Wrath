extends Node
@export var PLUNGE_DAMAGE_MULTIPLIER = .3 ## 30 percent more damage each second when falling
@export var STATE_ANIMATION_PLAYER: AnimationPlayer ## Players state animation player
@export var PLUNGE_ANIMATIONS: Array[String] = ["PLUNGE", "PLUNGE_FALL","JUMPING", "FALL"]
@export var ATTACK_AREA: Area3D
var falling: float = 0.0

func increase_damage_plunge():
	if ATTACK_AREA: 
		#print(falling)
		ATTACK_AREA.damage_multiplier = 1.0 + (falling * PLUNGE_DAMAGE_MULTIPLIER)
		falling = 0.0

func reset_damage():
	if ATTACK_AREA: ATTACK_AREA.damage_multiplier = 1

func load_plunge_damage()-> void:
	PLUNGE_DAMAGE_MULTIPLIER   = Save.data.get("plunge_multiplier", PLUNGE_DAMAGE_MULTIPLIER)

func _ready() -> void:
	load_plunge_damage()
	Save.connect("save_data_updated", load_plunge_damage)

func _physics_process(delta: float) -> void:
	falling += delta
	
	if not STATE_ANIMATION_PLAYER.current_animation in PLUNGE_ANIMATIONS:
		falling = 0.0
