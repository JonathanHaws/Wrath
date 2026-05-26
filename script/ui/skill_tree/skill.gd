extends Control

@export_multiline var description: String = "Increases players power" ## Relevant infol
@export var prerequisite_node: Node ## The node that must be aquired before this one can be purchased. (Previous node skill tree) 
@export var save_key: String ## Special save data key to read if this has been aquired yet. If left empty key will be auto generated prefixed with unique node branch path
@export var upgrade_key: String = "health" ## The save key to update 
@export var new_amount: Variant = 1.0 ## The update value for the property
@export var cost: float = 5 ## Price for upgrading. Amount less then 0 means skill is not purchasable 
@export var currency_key: String = "wisp" ## How much it costs to buy this skill. 

@export var button: TextureButton
@export var locked_texture: Texture2D = preload("res://textures/menu/skill_tree/skills/Skills-locked.png")
@export var texture: Texture2D

@export_subgroup("INFO")
@export var description_group: String = "ability_info_skilltree" ## Add the Label which should say the description of the ability to this group
@export var cost_group: String = "cost_skilltree" ## Add the Label which should say the cost of this ability to this group

@export var open_animation: AnimationPlayer ## The animation player which controls opening and closing animations
@export var state_animation: AnimationPlayer ## The animation player which controls how the skill looks in different states
@export var hover_animation: AnimationPlayer ## The animation player which controls how skills look when hovered

@export_subgroup("Line")
@export_range(0.0, 1.0) var padding: float = 0.38
@export var line_node: Line2D
func generate_line():
	if not line_node: return
	if prerequisite_node == null: 
		line_node.queue_free()
		return

	#line_node = Line2D.new()
	#line_node.width = 4
	#line_node.default_color = Color8(204, 204, 204)
	#line_node.z_index = -1
	#line_node.begin_cap_mode = Line2D.LINE_CAP_ROUND
	#line_node.end_cap_mode = Line2D.LINE_CAP_ROUND
	#
	var start: Vector2 = line_node.to_local(global_position) + pivot_offset
	var end: Vector2 = line_node.to_local(prerequisite_node.global_position) + pivot_offset
	#line_node.set_point_position(1, end)
	var a: Vector2 = start.lerp(end, 0.38)
	var b: Vector2 = start.lerp(end, 0.62)
	#
	line_node.clear_points()
	line_node.add_point(a)
	line_node.add_point(b)
	#
	#line_node.z_index = get_parent().z_index
#
	#get_parent().add_child(line_node)


var prerequisite_key
var aquired_key

func is_acquired() -> bool:
	return Save.data.has(aquired_key)

func is_locked() -> bool:
	if prerequisite_node and not Save.data.has(prerequisite_key): return true
	return false

func is_available() -> bool:
	return not is_locked() and not is_acquired()


@export_group("AUDIO") ## Multiple skills can share same same player with refrence by group
@export var hover_sound_group: String = "skill_hover_sound" ## Sound to be played when hovered.
@export var insufficient_funds_sound_group: String = "skill_insufficent_funds_sound" ## Sound to be played when declined.
@export var purchased_sound_group: String = "skill_purchased_sound_group_sound" ## Sound to be played when skill is bought.
func play_group_sound(group_name: String) -> void:
	if not is_visible_in_tree(): return
	for node in get_tree().get_nodes_in_group(group_name):
		if node is AudioStreamPlayer: node.play()

func setup_focus():
	if focus_previous.is_empty(): focus_previous = get_path()
	if focus_next.is_empty(): focus_next = get_path()
	if focus_neighbor_top.is_empty(): focus_neighbor_top = get_path()
	if focus_neighbor_bottom.is_empty(): focus_neighbor_bottom = get_path()
	if focus_neighbor_left.is_empty(): focus_neighbor_left = get_path()
	if focus_neighbor_right.is_empty(): focus_neighbor_right = get_path()

	if prerequisite_node:
		var p = prerequisite_node.get_path()
		if prerequisite_node.focus_neighbor_right.is_empty() or prerequisite_node.focus_neighbor_right == p:
			prerequisite_node.focus_neighbor_right = get_path()
		focus_neighbor_left = p

@warning_ignore("unused_signal")
signal unfurl
signal acquired


func _on_unfurl():
	visible = true
	if open_animation:
		open_animation.stop()
		open_animation.play("open")

func _on_visibility_changed():
	if visible and open_animation:
		open_animation.stop()
		if prerequisite_node: 
			open_animation.play("close")
		else:
			open_animation.play("open")

func enter_hovered():
	if is_locked(): return
	if hover_animation: hover_animation.play("enter_hover")
	play_group_sound(hover_sound_group)
	for n in get_tree().get_nodes_in_group(cost_group): n.text = str(cost)
	for n in get_tree().get_nodes_in_group(description_group): n.text = description
	
func exit_hovered():
	if is_locked(): return
	if hover_animation: hover_animation.play("exit_hover")
	
func _on_prequisite_acquired():
	update_state_animation(false)
	

func resolve_save_keys():
	# will auto generate unique save keys if ones are not provided
	if save_key: aquired_key = save_key
	else: aquired_key = Save.get_unique_key(self,"skill_node")
	
	if prerequisite_node: 
		prerequisite_key = Save.get_unique_key(prerequisite_node, "skill_node")
		if prerequisite_node.save_key != "": prerequisite_key = prerequisite_node.save_key

func update_state_animation(play_instantly: bool = false):
	if not get_node_or_null("State"): return
	if is_acquired(): $State.play("acquired")
	elif is_locked(): $State.play("locked")
	else: $State.play("available")
	if play_instantly:
		$State.advance($State.current_animation_length - $State.current_animation_position)

func _ready():
	
	resolve_save_keys()
	update_state_animation(true)
	
	if button: button.texture_normal = texture
	
	if prerequisite_node:
		if prerequisite_node.has_signal("unfurl"):
			prerequisite_node.unfurl.connect(_on_unfurl)
	
	if open_animation: open_animation.play("close")
	
	z_index +=1
	
	if button:
		button.button_down.connect(_on_pressed)
		button.mouse_entered.connect(enter_hovered)
		button.mouse_exited.connect(exit_hovered)
		button.focus_entered.connect(enter_hovered)
		button.focus_exited.connect(exit_hovered)

	visibility_changed.connect(_on_visibility_changed)
	
	if prerequisite_node and prerequisite_node.has_signal("acquired"):
		prerequisite_node.acquired.connect(_on_prequisite_acquired)

	setup_focus()
	call_deferred("generate_line")
	
	
func _on_pressed():
	if cost < 0: return
	if not Save.data.has(currency_key): Save.data[currency_key] = 0

	if is_locked():
		play_group_sound(insufficient_funds_sound_group)
		return
		
	if 	Save.data[currency_key] < cost:
		play_group_sound(insufficient_funds_sound_group)
		return
	
	if is_acquired(): return
	play_group_sound(purchased_sound_group)
	Save.data[currency_key] -= cost
	Save.data[upgrade_key] = new_amount
	if $State: $State.play("acquired")
	Save.data[aquired_key] = true
	Save.save_game()
	acquired.emit()

	#print('upgraded ', upgrade_key, " ", new_amount)
