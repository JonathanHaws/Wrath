extends Node
@export var disabled: bool = false

@export_group("Trigger Area")
@export var trigger_area: Area3D ## Only triggers from target body
@export var animation_player: AnimationPlayer 
@export var animation_name: StringName = &""

@export_group("Target Animation")
@export var target_anim_group: String = "player_anim" ## Animationg player group to trigger animation
@export var target_anim: StringName = &"" ## Corresponding animation 

@export_group("Interpolate Transforms") 
@export_subgroup("Transforms")
## Todo (add collision options where collision can be disabled to prioritize the visual. and transform reset to original if one of the bodies got stuck in a wall)
@export var interpolate: bool = true
@export var body: Node3D ## Transform to be aligned
@export var mesh: Node3D ## Orientation will be reset on this object so only have to worry about aligning bodies
@export var target_body_group: String = "player_body" ## Transform in other other object to be aligned
@export var target_mesh_group: String = "player_mesh" ## Orientation will be reset on this object so only have to worry about aligning bodies

@export_subgroup("Interpolation")## Remember animation tracks properties are update top to bottom in track list
@export_range(0.0, 10.0, 0.01, "or_greater") var duration_seconds: float = 0.0 ## Determines how long the tween takes to align transforms 
@export_range(0.0, 1.0, 0.01) var weight: float = 0.5 ## Determines who stays still versus who moves. Usually only want target to move (0). Middle is (0.5)
@export_range(0.0, 1.0, 0.01) var rotation_weight: float = 0.5
func _get_middle_transform(target_mesh: Node3D) -> Transform3D:
	return mesh.global_transform.interpolate_with(target_mesh.global_transform, weight)

func _on_body_entered(other_body: Node3D) -> void:
	if disabled: return
	if not other_body.is_in_group(target_body_group): return
	if not animation_player: return
	if animation_name == &"": return
	if animation_player.is_playing(): return
	animation_player.play(animation_name)	

func _match_transforms() -> void:
	
	var target_mesh = get_tree().get_first_node_in_group(target_mesh_group)
	var target_body = get_tree().get_first_node_in_group(target_body_group)
	if not target_mesh or not target_body: return

	var middle = _get_middle_transform(target_mesh)
	
	if duration_seconds > 0.0:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_process_mode(Tween.TweenProcessMode.TWEEN_PROCESS_PHYSICS)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)

		tween.tween_property(body, "global_transform", middle, duration_seconds)
		tween.tween_property(target_body, "global_transform", middle, duration_seconds)
		tween.tween_property(mesh, "global_transform", middle, duration_seconds)
		tween.tween_property(target_mesh, "global_transform", middle, duration_seconds)
		
	else: 
		if body: body.global_transform = middle
		target_body.global_transform = middle
		mesh.global_transform = middle
		target_mesh.global_transform = middle
		
		#print("Child Local Transform:", child_transform.transform)
		#print("Target Child Local Transform:", target_child_transform.transform)
				
func _trigger_corresponding_animation() -> void:
	if disabled: return
	for node in get_tree().get_nodes_in_group(target_anim_group):
		if not node is AnimationPlayer: continue
		if not node.has_animation(target_anim): continue
		node.play(target_anim)
		node.seek(node.current_animation_position, true) # CRUCIAL LINE MAKES IT SO TARGET STATE IS SET RIGHT BEFORE MATCHING TRANSFORM
		
	if interpolate:	_match_transforms()	#ALWAYS DO THIS AFTER TRIGGERING OTHER ANIMATION

func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_body_entered)
