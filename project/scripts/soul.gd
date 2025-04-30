extends Node3D
@export var AREA: Area3D
@export var REAPER: CharacterBody3D
@export var COLLECTION_SOUNDS: Array[AudioStream] = []
@export var UPGRADE = 5.0
@export var HEALTH = true

func _freeze(duration: float, speed: float = 0.0) -> void:
	SlowMotion.impact(duration, speed)

func _on_body_entered(body: Node) -> void:
	if not body == REAPER: return
	$AnimationPlayer.play("delay_upgrade")
	Audio.play_2d_sound(COLLECTION_SOUNDS[randi() % COLLECTION_SOUNDS.size()], 0.9, 1.1)

func _upgrade() -> void:
	if HEALTH:
		Save.data["max_health"] += UPGRADE
		REAPER.health += UPGRADE
		REAPER.HEALTH_BAR.max_value = Save.data["max_health"]
		REAPER.MAX_HEALTH = Save.data["max_health"]
		REAPER.HEALTH_BAR.size.x = REAPER.MAX_HEALTH * REAPER.BAR_PIXEL_WIDTH
	else:
		Save.data["max_stamina"] += UPGRADE
		REAPER.stamina += UPGRADE
		REAPER.STAMINA_BAR.max_value = Save.data["max_stamina"]
		REAPER.MAX_STAMINA = Save.data["max_stamina"]
		REAPER.STAMINA_BAR.size.x = REAPER.MAX_STAMINA * REAPER.BAR_PIXEL_WIDTH
		
	Save.data[self.name] = true
	Save.save_game()

func _ready() -> void:
	
	if Save.data.has(self.name) and Save.data[self.name] == true:
		queue_free()
	
	AREA.connect("body_entered", Callable(self, "_on_body_entered"))
