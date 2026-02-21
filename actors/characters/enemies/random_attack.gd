extends Node # Child node to animation player to specify attacks based of randomness, promximity, and boss health
@export var ATTACK_LIKELEHOOD_PER_SECOND: Curve
@export var TRIGGER_ANIMATIONS: Array[String] = ["CHASE"] ## Requires animation player to be playing specific animations to trigger an attack... If no required trigger will trigger no matter the current animation
@export var DISABLED: bool = false
@export var ATTACK_ANIMATION: String = "SLAM"
@export var LIKELIHOOD_MULTIPLIER: float = 1.0 ## Easy value for adjusting the overall frequency
@export var ATTACK_RADIUS: float = 10.0
@export var COOLDOWN: float = 1.0 ## After an attack finishes... How long before they can use it again
@export var COOLDOWN_REMAINING: float = 1.0 ## Used to disable this attack at the start of the scene

@export_group("Area Multipliers") ## Used to trigger attacks when the player is in specific spots
@export var AREAS: Array[Area3D] = [] ## The areas which will multiply the liklehood of an attack
@export var AREA_LIKELIHOOD_VALUES: Array[float] = [] ## Coresponding array to areas which specify how the final likelehood will be affected
@export var DEFAULT_AREA_LIKELIHOOD: float = 0.0 ## Used if areas exist but none overlap.
func get_area_likelihood_multiplier() -> float:
	if AREAS.size() < 1: return 1.0
	
	var area_multiplier: float = DEFAULT_AREA_LIKELIHOOD
	for i in AREAS.size():
		if i >= AREA_LIKELIHOOD_VALUES.size(): continue
		var area: Area3D = AREAS[i]
		var value: float = AREA_LIKELIHOOD_VALUES[i]
		if area.overlaps_body(TARGET.target):
			area_multiplier += value

	#print(area_multiplier)
	return max(area_multiplier, 0.0) 

@export_group("Phase") ## Used for disalbing certain attacks until the proper phase. Accelerating difficulty makes bosses exiciting 
@export var HITSHAPE: Node ## Percentage determined by health / max_health
@export var HEALTH_HIGH_THRESHOLD: float = 10.0   ## 0.5 = 50%
@export var HEALTH_LOW_THRESHOLD: float = 0.0   ## 0.5 = 50%

@export_group("References")
@export var ANIM: AnimationPlayer ## Animation player to trigger
@export var TARGET: Node3D ## Used to calculate the proximity or distance to weigth attacks 
@export var BODY: Node3D

func _ready() -> void:
	if not ANIM: ANIM = get_parent() as AnimationPlayer

func _physics_process(delta: float) -> void:

	if not ANIM: return
	if DISABLED: return

	if COOLDOWN_REMAINING > 0.0:
		if ANIM.current_animation == ATTACK_ANIMATION: return
		COOLDOWN_REMAINING -= delta
		return

	if HITSHAPE and "HEALTH" in HITSHAPE and "MAX_HEALTH" in HITSHAPE:
		var hp_ratio: float = float(HITSHAPE.HEALTH) / float(HITSHAPE.MAX_HEALTH)
		if hp_ratio > HEALTH_HIGH_THRESHOLD or hp_ratio < HEALTH_LOW_THRESHOLD: return

	if TRIGGER_ANIMATIONS.size() > 0 and not (ANIM.current_animation in TRIGGER_ANIMATIONS): return

	var proximity_likelihood = 0
	if not BODY or not TARGET or not ATTACK_LIKELEHOOD_PER_SECOND: proximity_likelihood = 0
	var distance = BODY.global_position.distance_to(TARGET.global_position)
	if distance > ATTACK_RADIUS: proximity_likelihood = 0
	proximity_likelihood = ATTACK_LIKELEHOOD_PER_SECOND.sample(clamp(distance / ATTACK_RADIUS, 0.0, 1.0))
	
	var area_likelihood: float = get_area_likelihood_multiplier()
		
	var chance = proximity_likelihood * area_likelihood * LIKELIHOOD_MULTIPLIER * delta
	if randf() < chance:
		ANIM.play(ATTACK_ANIMATION)
		ANIM.advance(0.0)
		COOLDOWN_REMAINING = COOLDOWN
		
	#print(chance)
