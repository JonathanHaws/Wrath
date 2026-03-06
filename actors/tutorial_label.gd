extends Control ## script for onboarding tutorial prompts... 
@export_group("Tutorial")
@export_multiline var base_text: String = "[key] [progress]" 
@export var action_name: String = "interact"
@export var saved_key: String = ""
@export var required_learn_count: int = 3
func get_key() -> String:
	var key_name: String = saved_key
	if key_name.is_empty():
		key_name = Save.get_unique_key(self, "learn")
	return key_name
func has_learned_tutorial() -> bool:
	return int(Save.data.get(get_key(), 0)) >= required_learn_count
@export_subgroup("Area")
@export var tutorial_area_group_name: String = "skill_tree_tutorial"
@export var player_body_group_name: String = "player_body"
@export var trigger_tutorial_with_area: bool = true
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(player_body_group_name): return
	if not Save.data.has(saved_key): Save.data[saved_key] = 0
	if not visible: play_reveal_animation()
	#print('player entered tutorial')

@export_group("Text")
@export var delimiter: String = "-" 
@export var key_placeholder: String = "key" ## Used to specify what text will be automatically replaced with ccontrols
@export var progress_placeholder: String = "progress" ## Used to track progress of how well player learned mechanic. 
@export var capitalize: bool = true
@export var progress_display_divider: int = 1 ## Used to make prgress display cleaner for toggle actions. really require 6/6 but show 3/3
@export_subgroup("Themes")
@export var key_color: Color = Color(0.475, 0.525, 0.608)  # #566987
@export var progress_color: Color = Color(0.549, 0.451, 0.394, 1.0) # optional
func set_tutorial_text() -> void:
	for child in get_children(): child.queue_free()

	var binding_text: String = Config.get_string_from_action(action_name)
	if capitalize: binding_text = binding_text.to_upper()

	var learn_count: int = int(Save.data.get(get_key(), 0))
	var display_count: int = int(float(learn_count) / progress_display_divider)
	var display_required: int = int(float(required_learn_count) / progress_display_divider)
	var progress_text: String = str(display_count) + "/" + str(display_required)

	var segments = base_text.split(delimiter)

	for segment in segments:
		var label := Label.new()
		if segment == key_placeholder:
			label.text = binding_text
			label.add_theme_color_override("font_color", key_color)
		elif segment == progress_placeholder:
			label.text = progress_text
			label.add_theme_color_override("font_color", progress_color)
		else:
			label.text = segment
		add_child(label)

@export_group("AUDIO") ## Audio player found by group and triggered
@export var revealed_sound: String = "tutorial_prompt" ## Sound to be played when revealed
@export var already_revealed_sound: String = "" ## Sound to be played when revealed
func play_group_sound(group_name: String) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		if node is AudioStreamPlayer: node.play()

@export_group("Animations")
@export_subgroup("Tweens")
@export_subgroup("Modulation")
var ready_modulation: bool = true
var reveal_modulation_tween: bool = true
var already_revealed_modulation_tween: bool = true
var learned_modulation_tween: bool = true
@export_subgroup("Players")
@export var revealed_player: AudioStreamPlayer ## Sound for when tutorial info is revealed
@export var animation_player: AnimationPlayer ## Animation to play when area is entered
@export var reveal_animation: String = "REVEAL"
@export var learned_animation: String = "LEARNED"
@export var already_revealed_animation: String = "REVEAL"
func play_reveal_animation() -> void:
	if reveal_modulation_tween: 
		create_tween().tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	if animation_player: animation_player.play(reveal_animation, 0)
	play_group_sound(revealed_sound)
	visible = true

func play_already_revealed_animation() -> void:
	if already_revealed_modulation_tween: 
		create_tween().tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	if animation_player: animation_player.play(already_revealed_animation, 0)
	play_group_sound(already_revealed_sound)
	visible = true

func play_learned_animation() -> void:
	if learned_modulation_tween: 
		create_tween().tween_property(self, "modulate", Color(1,1,1,0), 0.5)
	if animation_player:
		animation_player.connect("animation_finished", Callable(self, "queue_free"))
		animation_player.play(learned_animation, 0)
	
func _ready():
	if ready_modulation: modulate = Color(1, 1, 1, 0)
	
	set_tutorial_text()
	if has_learned_tutorial(): queue_free()
	
	if trigger_tutorial_with_area and Save.data.has(saved_key): # if player has key they have already enetered this area in the past
		play_already_revealed_animation()
		
	if trigger_tutorial_with_area and not Save.data.has(saved_key):
		visible = false
		for area in get_tree().get_nodes_in_group(tutorial_area_group_name):
			area.connect("body_entered", Callable(self, "_on_body_entered"))
	
	if not trigger_tutorial_with_area:
		visible = true
		if animation_player: play_reveal_animation()
	
func _process(_delta):
	if Input.is_action_just_pressed(action_name):
		Save.data[saved_key] = int(Save.data.get(saved_key, 0)) + 1	# increment
		set_tutorial_text()
		if has_learned_tutorial(): play_learned_animation()
		
