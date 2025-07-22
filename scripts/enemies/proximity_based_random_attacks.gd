extends AnimationPlayer
@export var ATTACK_ANIMATION: Array[String] = []
@export var ATTACK_RADIUS: Array[float] = []
@export var ATTACK_LIKELEHOOD: Array[Curve] = []
@export var LIKELIHOOD_MULTIPLIERS: Array[float] = [] #Attacks Pers Second on average
@export var LIKELIHOOD_MULTIPLIER: float = 1.0
@export var ATTACKING: bool = false
@export var TARGET: Node3D
@export var BODY: Node3D

func play_random_attack(position: Vector3, target_position: Vector3, delta: float) -> void:
	#print("Playing attack:", ATTACK_ANIMATION[i])
	var indices = range(ATTACK_ANIMATION.size())  
	indices.shuffle();  #print(indices) # randomly sort attacks to distrubte priorty
	for i in indices:
		var distance = position.distance_to(target_position)
		if distance > ATTACK_RADIUS[i]: continue
		var normalized_distance = clamp(distance / ATTACK_RADIUS[i], 0.0, 1.0)
		var attack_likelihood = ATTACK_LIKELEHOOD[i].sample(normalized_distance)
		attack_likelihood *= LIKELIHOOD_MULTIPLIERS[i] * LIKELIHOOD_MULTIPLIER
		if randf() < (attack_likelihood * delta):
			play(ATTACK_ANIMATION[i])
			break

func _physics_process(delta: float) -> void:
	if BODY and TARGET:
		
		#var debug_radius: float = 40.0
		#var normalized_distance = clamp(BODY.global_position.distance_to(TARGET.global_position) / debug_radius, 0.0, 1.0)
		#print("Normalized distance:", normalized_distance)
		
		play_random_attack(BODY.global_position, TARGET.global_position,delta)
		
