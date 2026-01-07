extends Node
@export var WISP_KEY := "wisp"
@export var AMOUNT : int = 1

@export_group("Collectable")
@export var SAVE_COLLECTED: bool = false ## Determines if colelctable will dissapear permantly or will repawn
@export var PLAYER_GROUP = "player" ## Group of nodes that can trigger upgrade
@export var TRIGGER_AREA: Area3D  ## The area that triggers the upgrade
@export var ANIM: AnimationPlayer
@export var ANIM_NAME: String = "delay_upgrade"
var collected

func give() -> void:
	if collected: return
	Save.data[WISP_KEY] = Save.data.get(WISP_KEY, 0) + AMOUNT
	if SAVE_COLLECTED: Save.data[Save.get_unique_key(self,"_collected")] = true
	Save.save_game()

func _on_body_entered(body: Node) -> void:
	if PLAYER_GROUP != "" and not body.is_in_group(PLAYER_GROUP): return
	ANIM.play(ANIM_NAME)
	
func _ready() -> void:
	if SAVE_COLLECTED: if Save.data.has(Save.get_unique_key(self,"_collected")): 
		collected = true
		self.visible = false
		if TRIGGER_AREA:
			TRIGGER_AREA.monitoring = false
			TRIGGER_AREA.monitorable = false
			
	if TRIGGER_AREA: TRIGGER_AREA.connect("body_entered", Callable(self, "_on_body_entered"))
