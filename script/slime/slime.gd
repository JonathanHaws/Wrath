extends CharacterBody3D

@export var nodes_to_delete_when_stuck: Array[Node]
@export var target: Node
@export var mesh: Node
@export var slime_stick_group: String = "slime_stick"
@export var player_body_group: String = "player_body"
@export var player_anim_group: String = "player_anim"
@export var allowed_animations: Array[String] = [ ## only able to stick to the player if in these states
	"IDLE",
	"RUN",
	"WALK",
	"JUMP",
	"FALL"
]

var stuck: bool = false

func get_first_in_group(group_name: StringName) -> Variant: # gets first node 
	return get_tree().get_nodes_in_group(group_name)[0]

func stick() -> void:
	if not get_first_in_group(player_body_group).SLIME_SPEED_MULTIPLIER == 1: return # already stuck
	if get_first_in_group(player_anim_group).current_animation not in allowed_animations: return
	
	for node in nodes_to_delete_when_stuck:
		if is_instance_valid(node): node.queue_free()

	stuck = true
	get_first_in_group(player_body_group).SLIME_SPEED_MULTIPLIER = 0.2
	$Audio/Slime.play_random_child()
	
	
	#print('stick')

func _unstick() -> void: 
	if stuck: get_first_in_group(player_body_group).SLIME_SPEED_MULTIPLIER = 1.0

func _physics_process(_delta: float) -> void:
	if not stuck: return
	target.MOVE_AND_SLIDE = false
	target.TRACKING_MULTIPLIER = 0
	target.SPEED_MULTIPLIER = 0
	if mesh: mesh.transform = Transform3D.IDENTITY
	global_transform = get_first_in_group(slime_stick_group).global_transform
