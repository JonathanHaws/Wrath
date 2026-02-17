extends Control
@export_group("Rich Text Label")
@export var label: Node
@export var action_name: String = "interact"
@export var place_holder_string: String = "[key]"
@export var capitalize: bool = true

@export_group("Save")
@export var save_learnt: bool = true
@export var saved_key: String = ""
@export var required_learn_count: int = 3
func queue_free_if_learnt() -> void:
	if not save_learnt: return
	
	var key_name: String = saved_key
	if key_name.is_empty():
		key_name = Save.get_unique_key(self, "learn")
	
	if int(Save.data.get(saved_key, 0)) >= required_learn_count:
	
		if animation_player and learned_animation != "" and animation_player.current_animation != learned_animation:
			animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
			animation_player.play(learned_animation, 0)
		else:
			queue_free()

@export_group("Animation")
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

@export_group("Audio")
@export var revealed_player: AudioStreamPlayer
@export var learning_player: AudioStreamPlayer

func _ready():
	var binding_text: String = Controls.get_action_bindings(action_name)
	if capitalize: binding_text = binding_text.to_upper()
	if "text" in label: label.text = label.text.replace(place_holder_string, binding_text)
	queue_free_if_learnt()
	
	if trigger_tutorial_with_area:
		visible = false

		if Save.data.has(saved_key) and int(Save.data[saved_key]) < required_learn_count: ## Stay revealed even if player goes to a different scene
			visible = true
			if animation_player: animation_player.play(already_revealed_animation, 0)
		
		for area in get_tree().get_nodes_in_group(tutorial_area_group_name):
			area.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		if animation_player: animation_player.play(reveal_animation, 0)
	
func _process(_delta):
	if save_learnt and Input.is_action_just_pressed(action_name) and visible:
		if learning_player: learning_player.play()
		queue_free_if_learnt()
		Save.data[saved_key] = int(Save.data.get(saved_key, 0)) + 1	# increment
