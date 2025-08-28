extends Node
@export var SKIPPABLE_GROUP: String = "skippable" ## Animation players to skip
@export var SKIPPABLE_MARKER: String = "skip" ## Where to skip in animations while still updating audio tracks, animations, and calling methods
@export var ANIMATION_PLAYER: AnimationPlayer
@export var ANIMATION_SKIPPING_NAME: StringName = &"SKIPPING" 
@export var ANIMATION_SKIPPED_NAME: StringName = &"SKIPPED" 

func skippable_animation_playing() -> bool: ## Returns wether theres any animation players playing an animation with skippable marker
	for node in get_tree().get_nodes_in_group(SKIPPABLE_GROUP):
		if node is AnimationPlayer and node.is_playing():
			if SKIPPABLE_MARKER in node.get_animation(node.current_animation).get_marker_names():
				if node.get_animation(node.current_animation).get_marker_time(SKIPPABLE_MARKER) > node.current_animation_position:
					return true
	return false

func _skip(play_fade: bool = true) -> void:
	for node in get_tree().get_nodes_in_group(SKIPPABLE_GROUP):
		if node is AnimationPlayer and node.is_playing():
			var anim = node.get_animation(node.current_animation)
			if SKIPPABLE_MARKER in anim.get_marker_names():
				var t = anim.get_marker_time(SKIPPABLE_MARKER)
				node.seek(t, true)
	
	if play_fade and ANIMATION_PLAYER and ANIMATION_SKIPPED_NAME != &"":
		ANIMATION_PLAYER.play(ANIMATION_SKIPPED_NAME)
				
func _process(_delta: float) -> void:
	if not ANIMATION_PLAYER: return
	if not skippable_animation_playing(): return
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_skip"):
		if not ANIMATION_PLAYER.is_playing(): ANIMATION_PLAYER.play(ANIMATION_SKIPPING_NAME)
		ANIMATION_PLAYER.speed_scale = 1.0
	else:
		if ANIMATION_PLAYER.speed_scale != -1.0: ANIMATION_PLAYER.speed_scale = -1.0 
		
	#print("Current time:", ANIMATION_PLAYER.current_animation_position)
