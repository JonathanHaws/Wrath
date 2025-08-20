extends Area3D	
@export var animation_player: AnimationPlayer	
@export var animation_name: StringName = &""	## Animation to play
@export var player_group_name: String = "player"
@export var player_anim_group: String = "player_anim" ## Player AnimationPlayer To trigger in the player
@export var player_anim: StringName = &"" ## Corresponding animation 

@export var transform_node: Node3D	## Node3D that will be moved to match player (rotated, translated, transformed)
@export var target_transform_node_group: String = "player_mesh"	## Node3D that will be moved to match player (rotated, translated, transformed)
var original_global_transforms: Dictionary = {}  


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group(player_group_name): return
	if not animation_player: return
	if not animation_name != &"": return
	if animation_player.is_playing(): return
	animation_player.play(animation_name)	

func _match_transforms(duration: float = 0.0, transform_weight: float = 1.0, position_weight: Vector3 = Vector3.ONE) -> void:
	if not transform_node: return
	for target in get_tree().get_nodes_in_group(target_transform_node_group):	
		
		if not original_global_transforms.has(transform_node):
			original_global_transforms[transform_node] = transform_node.global_transform
		if not original_global_transforms.has(target):
			original_global_transforms[target] = target.global_transform

		# interpolate per axis
		var start = transform_node.global_transform
		var end = target.global_transform
		var middle_transform = start
		middle_transform.origin = start.origin.lerp(end.origin, transform_weight)
		middle_transform.origin = Vector3(
			lerp(start.origin.x, end.origin.x, position_weight.x),
			lerp(start.origin.y, end.origin.y, position_weight.y),
			lerp(start.origin.z, end.origin.z, position_weight.z)
		)
		
		var tween1 = create_tween()
		tween1.tween_property(transform_node, "global_transform", middle_transform, duration)
		
		var tween2 = create_tween()
		tween2.tween_property(target, "global_transform", middle_transform, duration)

func _trigger_corresponding_animation() -> void:
	for node in get_tree().get_nodes_in_group(player_anim_group):
		if not node is AnimationPlayer: continue
		if not node.has_animation(player_anim): continue
		node.play(player_anim)

func _ready() -> void:
	body_entered.connect(_on_body_entered)	# watch for bodies entering
