extends Node
@export var SKIPPABLE_GROUP: String = "skippable" ## Animation players that have skippable animations
@export var SKIP_MARKER: String = "skip" ## Animation marker name Where to skip in animations while still updating audio tracks, animations, and calling methods
@export var DESTROY_GROUP: String = "destroy_on_skip" ## Items to destroy when skipping
@export var ANIMATION_PLAYER_GROUP: String = "skip_animation_player"## Animation player for the overlay animations
@export var ANIMATION_SKIPPING_BY_HOLD: String = "SKIPPING" ## Animation name that fills up skip
@export var ANIMATION_SKIPPED_BY_HOLD: String = "SKIPPED_BY_HOLD" ## Animation name for when skip by hold 
@export var ANIMATION_SKIPPED_BY_BUTTON: String = "SKIPPED_BY_BUTTON" ## Animation name for when skipped by button
@export var PAUSE_MENU_GROUP: String = "pause_menu" ## Animation name for when skip has been confirmed
@export var SKIP_BUTTON: Button

func skippable_animation_playing() -> bool: ## Returns wether theres any animation players playing an animation with skippable marker
	for node in get_tree().get_nodes_in_group(SKIPPABLE_GROUP):
		if node is AnimationPlayer and node.is_playing():
			if SKIP_MARKER in node.get_animation(node.current_animation).get_marker_names():
				if node.get_animation(node.current_animation).get_marker_time(SKIP_MARKER) > node.current_animation_position:
					return true
	return false

func get_animation_player() -> AnimationPlayer:
	var nodes = get_tree().get_nodes_in_group(ANIMATION_PLAYER_GROUP)
	if nodes.size() > 0: return nodes[0] as AnimationPlayer
	return null

func _skip_by_hold() -> void:
	_skip(ANIMATION_SKIPPED_BY_HOLD)

func _skip_by_button() -> void:
	_skip(ANIMATION_SKIPPED_BY_BUTTON) 

func _skip(skipped_animation: String = "") -> void:
	
	#print('skip')
	
	for pause_menu in get_tree().get_nodes_in_group(PAUSE_MENU_GROUP):
		pause_menu.toggle(false) # Unpause if skipped from button
	
	for node in get_tree().get_nodes_in_group(SKIPPABLE_GROUP):
		if node is AnimationPlayer and node.is_playing():
			var anim = node.get_animation(node.current_animation)
			if SKIP_MARKER in anim.get_marker_names():
				var target_time = anim.get_marker_time(SKIP_MARKER)
				node.advance(target_time - node.current_animation_position)
	
	var animation_player = get_animation_player()
	if animation_player and skipped_animation != "": 
		animation_player.speed_scale = 1
		animation_player.play(skipped_animation, 0)
		animation_player.advance(0)
	
	await get_tree().process_frame
	await get_tree().physics_frame
	
	for node in get_tree().get_nodes_in_group(DESTROY_GROUP):
		node.queue_free()
		
func _ready() -> void:
	if SKIP_BUTTON:
		SKIP_BUTTON.pressed.connect(_skip_by_button)	
				
func _process(_delta: float) -> void:
	
	if not skippable_animation_playing(): 
		if SKIP_BUTTON and SKIP_BUTTON.visible: 
			SKIP_BUTTON.visible = false
		return
	if SKIP_BUTTON and not SKIP_BUTTON.visible: SKIP_BUTTON.visible = true
	
	var animation_player = get_animation_player()
	if not animation_player: return
	if Input.is_action_pressed("skip"):
		if not animation_player.is_playing(): animation_player.play(ANIMATION_SKIPPING_BY_HOLD)
		animation_player.speed_scale = 1.0
	else:
		if animation_player.speed_scale != -1.0: animation_player.speed_scale = -1.0 
		
	#print("Current time:", ANIMATION_PLAYER.current_animation_position)
