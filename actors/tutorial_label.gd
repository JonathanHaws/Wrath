extends Control
@export_group("Rich Text Label")
@export var label: Node
@export var action_name: String = "interact"
@export var place_holder_string: String = "[key]"
@export var capitalize: bool = true
func set_tutorial_text() -> void:
	var binding_text: String = Controls.get_action_bindings(action_name)
	if capitalize: binding_text = binding_text.to_upper()
	if "text" in label: label.text = label.text.replace(place_holder_string, binding_text)

@export_group("Save")
@export var saved_key: String = ""
@export var required_learn_count: int = 3
func get_key() -> String:
	var key_name: String = saved_key
	if key_name.is_empty():
		key_name = Save.get_unique_key(self, "learn")
	return key_name
func has_learned_tutorial() -> bool:
	return int(Save.data.get(get_key(), 0)) >= required_learn_count

@export_group("Animation")
@export var revealed_player: AudioStreamPlayer ## Sound for when tutorial info is revealed
@export var animation_player: AnimationPlayer ## Animation to play when area is entered
@export var reveal_animation: String = "REVEAL"
@export var learned_animation: String = "LEARNED"
@export var already_revealed_animation: String = "REVEAL"
func _on_animation_finished(_anim_name: String) -> void:
	queue_free()

@export_group("Area")
@export var trigger_tutorial_with_area: bool = true
@export var tutorial_area_group_name: String = "skill_tree_tutorial"
@export var player_body_group_name: String = "player_body"
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(player_body_group_name): return
	if not Save.data.has(saved_key): Save.data[saved_key] = 0
	if not visible:
		if revealed_player: revealed_player.play()
		if animation_player: animation_player.play(reveal_animation, 0)
		visible = true
	#print('player entered tutorial')

func _ready():
	set_tutorial_text()
	if has_learned_tutorial(): queue_free()
	
	if trigger_tutorial_with_area:
		if Save.data.has(saved_key): # if player has key they have already enetered this area in the past
			if animation_player: animation_player.play(already_revealed_animation, 0)
		else:
			visible = false
			for area in get_tree().get_nodes_in_group(tutorial_area_group_name):
				area.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		if animation_player: animation_player.play(reveal_animation, 0)
	
func _process(_delta):
	if Input.is_action_just_pressed(action_name) and visible:
		Save.data[saved_key] = int(Save.data.get(saved_key, 0)) + 1	# increment
		
		if has_learned_tutorial():
			if animation_player and learned_animation != "" and animation_player.current_animation != learned_animation:
				animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
				animation_player.play(learned_animation, 0)
			else:
				queue_free()
