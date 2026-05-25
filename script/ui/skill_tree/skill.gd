extends TextureButton
@export_multiline var description: String = "Increases players power" ## Relevant infol
@export var prerequisite_node: Node ## The node that must be aquired before this one can be purchased. (Previous node skill tree) 
@export var save_key: String ## Special save data key to read if this has been aquired yet. If left empty key will be auto generated prefixed with unique node branch path
@export var upgrade_key: String = "health" ## The save key to update 
@export var new_amount: Variant = 1.0 ## The update value for the property
@export var cost: float = 5 ## Price for upgrading. Amount less then 0 means skill is not purchasable 
@export var currency_key: String = "wisp" ## How much it costs to buy this skill. 
@onready var open_animation: AnimationPlayer = get_node_or_null("Open")
@onready var state_animation: AnimationPlayer = get_node_or_null("State")

@export_subgroup("INFO")
@export var description_group: String = "ability_info_skilltree" ## Add the Label which should say the description of the ability to this group
@export var cost_group: String = "cost_skilltree" ## Add the Label which should say the cost of this ability to this group
@onready var unlocked_texture = texture_normal
@export var generate_line_enabled: bool = true
@export_range(0.0, 1.0) var padding: float = 0.38
var line_node: Line2D
func generate_line():
	if not generate_line_enabled: return
	if prerequisite_node == null: return
	if line_node and is_instance_valid(line_node): line_node.queue_free() # avoid duplicates

	line_node = Line2D.new()
	line_node.width = 4
	line_node.default_color = Color8(204, 204, 204)
	line_node.z_index = -1
	line_node.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line_node.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	var start: Vector2 = prerequisite_node.position + prerequisite_node.pivot_offset
	var end: Vector2 = position + pivot_offset
	var a: Vector2 = start.lerp(end, 0.38)
	var b: Vector2 = start.lerp(end, 0.62)
	
	line_node.clear_points()
	line_node.add_point(a)
	line_node.add_point(b)
	
	line_node.z_index = get_parent().z_index

	get_parent().add_child(line_node)
	_on_save_data_updated()

@export_subgroup("MODULATION")
@export var base_modulate: Color = Color(.3,.3,.3,1)
@export var hover_modulate: Color = Color(0.5,0.5,0.5,1)	
@export var aquired_modulate: Color = Color(.9,.9,.9,1)
@export var locked_modulate: Color = Color(0.15, 0.15, 0.15, 0.188) 

var prerequisite_key
var aquired_key
func is_acquired() -> bool:
	return Save.data.has(aquired_key)
func is_locked() -> bool:
	if is_acquired():
		return false
	if prerequisite_node and not Save.data.has(prerequisite_key):
		return true
	return false

@export_group("AUDIO") ## Multiple skills can share same same player with refrence by group
@export var hover_sound_group: String = "skill_hover_sound" ## Sound to be played when hovered.
@export var insufficient_funds_sound_group: String = "skill_insufficent_funds_sound" ## Sound to be played when declined.
@export var purchased_sound_group: String = "skill_purchased_sound_group_sound" ## Sound to be played when skill is bought.
func play_group_sound(group_name: String) -> void:
	if not is_visible_in_tree(): return
	for node in get_tree().get_nodes_in_group(group_name):
		if node is AudioStreamPlayer: node.play()

@export var locked_texture: Texture2D = preload("res://textures/menu/skill_tree/skills/Skills-locked.png")

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
	
	if open_animation: 
		open_animation.play("enter_hover")
	
	play_group_sound(hover_sound_group)
	if not is_acquired(): modulate = hover_modulate
	for n in get_tree().get_nodes_in_group(cost_group): n.text = str(cost)
	for n in get_tree().get_nodes_in_group(description_group): n.text = description
	
func exit_hovered():
	if is_locked(): return
	
	if open_animation: open_animation.play("exit_hover")
	
	if is_acquired():
		modulate = aquired_modulate
	elif is_locked():
		modulate = locked_modulate
	else:
		modulate = base_modulate

func _on_save_data_updated():
	
	if line_node: 
		if is_locked():
			line_node.modulate = locked_modulate
		else: 
			line_node.modulate = base_modulate
	
	if is_locked():
		if locked_texture:
			texture_normal = locked_texture
	else:
		texture_normal = unlocked_texture		
	
	if is_acquired():
		modulate = aquired_modulate
	elif is_locked():
		modulate = locked_modulate
	else:
		modulate = base_modulate

func _ready():
	
	if prerequisite_node:
		if prerequisite_node.has_signal("unfurl"):
			prerequisite_node.unfurl.connect(_on_unfurl)
	
	if open_animation: open_animation.play("close")
	
	z_index +=1
	
	if save_key: aquired_key = save_key
	else: aquired_key = Save.get_unique_key(self,"skill_node")
	
	if prerequisite_node: 
		prerequisite_key = Save.get_unique_key(prerequisite_node, "skill_node")
		if prerequisite_node.save_key != "": prerequisite_key = prerequisite_node.save_key

	button_down.connect(_on_pressed)
	mouse_entered.connect(enter_hovered)
	mouse_exited.connect(exit_hovered)
	focus_entered.connect(enter_hovered)
	focus_exited.connect(exit_hovered)

	visibility_changed.connect(_on_visibility_changed)

	setup_focus()
	call_deferred("generate_line")
	
	Save.save_data_updated.connect(_on_save_data_updated)
	_on_save_data_updated()
	
func _on_pressed():

	if cost < 0: return
	
	if not Save.data.has(currency_key): 
		Save.data[currency_key] = 0
	
	if prerequisite_node and not Save.data.has(prerequisite_key):
		play_group_sound(insufficient_funds_sound_group)
		return
		
	if 	Save.data[currency_key] < cost:
		play_group_sound(insufficient_funds_sound_group)
		return
	
	if Save.data.has(aquired_key): return
	
	Save.data[currency_key] -= cost
	Save.data[upgrade_key] = new_amount
	#print('upgraded ', upgrade_key, " ", new_amount)
	
	play_group_sound(purchased_sound_group)
	
	if state_animation: state_animation.play("acquired")
	
	Save.data[aquired_key] = true
	modulate = aquired_modulate
	Save.save_game()
