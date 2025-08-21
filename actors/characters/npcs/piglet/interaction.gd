extends Node
@export_group("Trigger Area")
@export var trigger_area: Area3D 
@export var animation_player: AnimationPlayer 
@export var animation_name: StringName = &"" ## Animation to play in this object
@export var target_body_group: String = "player" ## Only trigger if body belongs to this group

@export_group("Target Animation")
@export var target_anim_group: String = "player_anim" ## Animationg player group to trigger animation
@export var target_anim: StringName = &"" ## Corresponding animation 

@export_group("Interpolate Transforms") ## Remember animation tracks properties are update top to bottom in track list
@export var parent_transform: Node3D## Transform to be aligned
@export var child_transform: Node3D	 ## Transform thats reset so only parent transform in this object needs to be aligned
@export var target_parent_transform_group: String = "player_body" ## Transform in other other object to be aligned
@export var target_child_transform_group: String = "player_mesh" ## Resets local transform so only parent transform has to be Aligned
@export_subgroup("Interpolation")## Remember animation tracks properties are update top to bottom in track list
@export_range(0.0, 10.0, 0.01, "or_greater") var duration_seconds: float = 0.0 ## Determines how long the tween takes to align transforms 
@export_range(0.0, 1.0, 0.01) var weight: float = 0.5 ## Determines how much influences each transform has on the meeting middle point

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group(target_body_group): return
	if not animation_player: return
	if not animation_name != &"": return
	if animation_player.is_playing(): return
	animation_player.play(animation_name)	

func _match_transforms() -> void:
	
	await get_tree().process_frame
	var tween = null
	if duration_seconds > 0.0:
		tween = create_tween()
		tween.set_parallel(true)
	
	for target_child_transform in get_tree().get_nodes_in_group(target_child_transform_group):
		for target_parent_transform in get_tree().get_nodes_in_group(target_parent_transform_group):	
			
			# Find global middle point between the childrens local transforms
			var middle = child_transform.global_transform.interpolate_with(target_child_transform.global_transform, weight)
			
			if tween: 
				tween.tween_property(child_transform, "global_transform", middle, duration_seconds)
				tween.tween_property(parent_transform, "global_transform", middle, duration_seconds)
				tween.tween_property(target_child_transform, "global_transform", middle, duration_seconds)
				tween.tween_property(target_parent_transform, "global_transform", middle, duration_seconds)
			else: 
				parent_transform.global_transform = middle
				child_transform.global_transform = middle
				target_parent_transform.global_transform = middle
				target_child_transform.global_transform = middle

				
		
func _trigger_corresponding_animation() -> void:
	_match_transforms()	
	for node in get_tree().get_nodes_in_group(target_anim_group):
		if not node is AnimationPlayer: continue
		if not node.has_animation(target_anim): continue
		node.play(target_anim)

func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_body_entered)

#func _process(delta: float) -> void: # For Debugging
	#
	#for node in get_tree().get_nodes_in_group(target_child_transform):
		#if node is Node3D:
			#print(node.name, "Target child transform:", node.transform)
	#
	#if child_transform:
		#print("My child_transform local:", child_transform.transform)
