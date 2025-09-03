extends AnimationPlayer

# make it so they use the rescource...

@export var ATTACK_ANIMATION: Array[String] = []
@export var ATTACK_RADIUS: Array[float] = []
@export var ATTACK_LIKELEHOOD: Array[Curve] = []
@export var LIKELIHOOD_MULTIPLIERS: Array[float] = [] ## Attacks Pers Second on average
@export var AREA_MULTIPLIERS: Array[Area3D] = [] ## Eg. Only let backstab happen if behind... Area that specifies whats considered behind... 
@export var LIKELIHOOD_MULTIPLIER: float = 1.0
@export var BLOCKING_ANIMATIONS: Array[String] = ["DEATH", "HURT"]
@export var BLOCK_IF_ATTACK_PLAYING: bool = true
@export var ATTACKING: bool = false
@export var TARGET: Node3D
@export var BODY: Node3D

## Add attack specfic cool downs also make attacks a seperate script so they can be saved as scenes... 
@export var attacks: Array = [
	{"name": "Slash", "radius": 3.0, "curve": null, "multiplier": 1.0, "area": null, "blocked": []},
]

func play_random_attack(position: Vector3, target_position: Vector3, delta: float) -> void:
	#print("Playing attack:", ATTACK_ANIMATION[i])
	var indices = range(ATTACK_ANIMATION.size())  
	indices.shuffle();  #print(indices) # randomly sort attacks to distrubte priorty
	for i in indices:
		var distance = position.distance_to(target_position)
		if distance > ATTACK_RADIUS[i]: continue
		var normalized_distance = clamp(distance / ATTACK_RADIUS[i], 0.0, 1.0)
		var attack_likelihood = ATTACK_LIKELEHOOD[i].sample(normalized_distance)
		
		var multiplier = 0.0
		if i < LIKELIHOOD_MULTIPLIERS.size():
			multiplier = LIKELIHOOD_MULTIPLIERS[i]
		
		# Stop new animation from playing if already in attack animation
		if BLOCK_IF_ATTACK_PLAYING and current_animation in ATTACK_ANIMATION: 
			multiplier = 0.0
			
		# If attack requires player to be inside and they are not set the likelehood to 0	
		if i < AREA_MULTIPLIERS.size() and AREA_MULTIPLIERS[i] and TARGET.target:
			if not AREA_MULTIPLIERS[i].overlaps_body(TARGET.target):
				multiplier = 0.0
			
		# Stop new animation from playing if in animation that shouldnt be interupted
		for blocked_anim in BLOCKING_ANIMATIONS: 
			if current_animation == blocked_anim:
				multiplier = 0.0
				break
		
		attack_likelihood *= multiplier * LIKELIHOOD_MULTIPLIER
		
		if randf() < (attack_likelihood * delta):
			play(ATTACK_ANIMATION[i])
			break

func _physics_process(delta: float) -> void:
	if BODY and TARGET:
		play_random_attack(BODY.global_position, TARGET.global_position,delta)
		#var debug_radius: float = 40.0
		#var normalized_distance = clamp(BODY.global_position.distance_to(TARGET.global_position) / debug_radius, 0.0, 1.0)
		#print("Normalized distance:", normalized_distance)

		
