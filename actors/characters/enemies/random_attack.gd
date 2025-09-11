extends Node
# Child node to animation player to specify attacks based of promximity and other things

@export var ATTACK_ANIMATION: String = "SLAM"
@export var LIKELIHOOD_MULTIPLIER: float = 1.0 ## Easy value for adjusting the overall frequency
@export var ATTACK_RADIUS: float = 10.0
@export var ATTACK_LIKELEHOOD_PER_SECOND: Curve
@export var AREA_MULTIPLIER: Area3D ## Eg. Only let backstab happen if behind... Area that specifies whats considered behind... 
@export var TRIGGER_ANIMATIONS: Array[String] = ["CHASE"] ## Requires animation player to be playing this animation trigger an attack...
@export var DISABLED: bool = false

@export_group("References")
@export var TARGET: Node3D
@export var BODY: Node3D

func _physics_process(delta: float) -> void:

	if DISABLED: return

	var player: AnimationPlayer = get_parent() as AnimationPlayer
	if not player: return
	if TRIGGER_ANIMATIONS.size() > 0 and not (player.current_animation in TRIGGER_ANIMATIONS): return

	var proximity_likelihood = 0
	if not BODY or not TARGET or not ATTACK_LIKELEHOOD_PER_SECOND: proximity_likelihood = 0
	var distance = BODY.global_position.distance_to(TARGET.global_position)
	if distance > ATTACK_RADIUS: proximity_likelihood = 0
	proximity_likelihood = ATTACK_LIKELEHOOD_PER_SECOND.sample(clamp(distance / ATTACK_RADIUS, 0.0, 1.0))
	
	var area_likelihood: float = 1.0
	if AREA_MULTIPLIER and not AREA_MULTIPLIER.overlaps_body(TARGET.target): area_likelihood = 0.0
	
	var chance = proximity_likelihood * area_likelihood * LIKELIHOOD_MULTIPLIER * delta
	if randf() < chance:
		player.play(ATTACK_ANIMATION)
		
	#print(chance)
