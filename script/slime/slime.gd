extends CharacterBody3D

@export var nodes_to_delete_when_stuck: Array[Node]
@export var target: Node
@export var mesh: Node
@export var player_body_group: String = "player_body"
@export var slime_stick_group: String = "slime_stick"
var stuck: bool = false

func get_player() -> Variant:
	return get_tree().get_nodes_in_group(player_body_group)[0]

func get_stick() -> Variant:
	return get_tree().get_nodes_in_group(slime_stick_group)[0]

func stick() -> void:
	if not get_player().SLIME_SPEED_MULTIPLIER == 1: return # already stuck
	
	for node in nodes_to_delete_when_stuck:
		if is_instance_valid(node): node.queue_free()

	stuck = true
	get_player().SLIME_SPEED_MULTIPLIER = 0.2
	
	#print('stick')

func _unstick() -> void: 
	if stuck: get_player().SLIME_SPEED_MULTIPLIER = 1.0

func _physics_process(_delta: float) -> void:
	if not stuck: return
	target.MOVE_AND_SLIDE = false
	target.TRACKING_MULTIPLIER = 0
	target.SPEED_MULTIPLIER = 0
	if mesh: mesh.transform = Transform3D.IDENTITY
	global_transform = get_stick().global_transform
