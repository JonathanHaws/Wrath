extends Node
@export var SKIPPABLE_GROUP: String = "skippable" ## Animation players that have skippable animations
@export var SKIP_MARKER: String = "skip" ## Animation marker name Where to skip in animations while still updating audio tracks, animations, and calling methods
@export var DESTROY_GROUP: String = "destroy_on_skip" ## Items to destroy when skipping
@export var ANIMATION_PLAYER: AnimationPlayer ## Animation player for the overlay
@export var ANIMATION_SKIPPING_NAME: String = "SKIPPING" ## Animation name that fills up skip
@export var ANIMATION_SKIPPED_NAME: String = "SKIPPED" ## Animation name for when skip has been confirmed
@export var SKIP_CALLBACK_GROUP: String = "skip_callback" ## For nodes that need to do extra function calls when skipped 
@export var SKIP_CALLBACK_METHOD: String = "on_skip" ## Name of functions to call

func skippable_animation_playing() -> bool: ## Returns wether theres any animation players playing an animation with skippable marker
	for node in get_tree().get_nodes_in_group(SKIPPABLE_GROUP):
		if node is AnimationPlayer and node.is_playing():
			if SKIP_MARKER in node.get_animation(node.current_animation).get_marker_names():
				if node.get_animation(node.current_animation).get_marker_time(SKIP_MARKER) > node.current_animation_position:
					return true
	return false

func _skip(play_fade: bool = true) -> void:
	for node in get_tree().get_nodes_in_group(SKIPPABLE_GROUP):
		if node is AnimationPlayer and node.is_playing():
			var anim = node.get_animation(node.current_animation)
			if SKIP_MARKER in anim.get_marker_names():
				var target_time = anim.get_marker_time(SKIP_MARKER)
				node.advance(target_time - node.current_animation_position)
	
	for node in get_tree().get_nodes_in_group(DESTROY_GROUP):
		node.queue_free()
	
	for node in get_tree().get_nodes_in_group(SKIP_CALLBACK_GROUP):
		if node.has_method(SKIP_CALLBACK_METHOD):
			node.call(SKIP_CALLBACK_METHOD)
	
	if play_fade: ANIMATION_PLAYER.play(ANIMATION_SKIPPED_NAME)
				
func _process(_delta: float) -> void:
	if not ANIMATION_PLAYER: return
	if not skippable_animation_playing(): return
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("skip"):
		if not ANIMATION_PLAYER.is_playing(): ANIMATION_PLAYER.play(ANIMATION_SKIPPING_NAME)
		ANIMATION_PLAYER.speed_scale = 1.0
	else:
		if ANIMATION_PLAYER.speed_scale != -1.0: ANIMATION_PLAYER.speed_scale = -1.0 
		
	#print("Current time:", ANIMATION_PLAYER.current_animation_position)
