extends Node # Child node to animation player to specify attacks based of randomness, promximity, and boss health
@export var ATTACK_ANIMATION: String = "SLAM"
@export var LIKELIHOOD_MULTIPLIER: float = 1.0 ## Easy value for adjusting the overall frequency
@export var ATTACK_RADIUS: float = 10.0
@export var ATTACK_LIKELEHOOD_PER_SECOND: Curve
@export var AREA_MULTIPLIER: Area3D ## Eg. Only let backstab happen if behind... Area that specifies whats considered behind... 
@export var TRIGGER_ANIMATIONS: Array[String] = ["CHASE"] ## Requires animation player to be playing specific animations to trigger an attack... If no required trigger will trigger no matter the current animation
@export var DISABLED: bool = false
@export var COOLDOWN: float = 1.0
var cooldown_remaining: float = 0.0

@export_group("Phase") ## Used for disalbing certain attacks until the proper phase. Accelerating difficulty makes bosses exiciting 
@export var PHASE_HITSHAPE: Node ## Percentage determined by health / max_health
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

	if cooldown_remaining > 0.0:
		if ANIM.current_animation == ATTACK_ANIMATION: return
		cooldown_remaining -= delta
		return


	if PHASE_HITSHAPE and "HEALTH" in PHASE_HITSHAPE and "MAX_HEALTH" in PHASE_HITSHAPE:
		var hp_ratio: float = float(PHASE_HITSHAPE.HEALTH) / float(PHASE_HITSHAPE.MAX_HEALTH)
		if hp_ratio > HEALTH_HIGH_THRESHOLD or hp_ratio < HEALTH_LOW_THRESHOLD: return

	if TRIGGER_ANIMATIONS.size() > 0 and not (ANIM.current_animation in TRIGGER_ANIMATIONS): return

	var proximity_likelihood = 0
	if not BODY or not TARGET or not ATTACK_LIKELEHOOD_PER_SECOND: proximity_likelihood = 0
	var distance = BODY.global_position.distance_to(TARGET.global_position)
	if distance > ATTACK_RADIUS: proximity_likelihood = 0
	proximity_likelihood = ATTACK_LIKELEHOOD_PER_SECOND.sample(clamp(distance / ATTACK_RADIUS, 0.0, 1.0))
	
	var area_likelihood: float = 1.0
	if AREA_MULTIPLIER and not AREA_MULTIPLIER.overlaps_body(TARGET.target): area_likelihood = 0.0
	
	var chance = proximity_likelihood * area_likelihood * LIKELIHOOD_MULTIPLIER * delta
	if randf() < chance:
		ANIM.play(ATTACK_ANIMATION)
		cooldown_remaining = COOLDOWN
		
	#print(chance)
