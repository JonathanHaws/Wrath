extends TextureButton
@export var cost := 5 ## Price for upgrading 
@export var currency_key: String = "wisp" 
@export var upgrade_key: String = "health" ## The save key to update 
@export var new_amount: Variant = 1.0 ## The update value for the property
@export var save_key: String ## Special save data key to read if this has been aquired yet. If left empty key will be auto generated prefixed with unique node branch path
@export var prerequisite_node: Node ## The node that must be aquired before this one can be purchased. (Previous node skill tree) 

@export_group("VISUALS")
@export_subgroup("INFO")
@export var cost_group:= "cost_skilltree" ## Label to update with cost of current skill node hovered
@export var description_group := "ability_info_skilltree" ## Label to update with a description of the ability
@export var description := "Increases players power"
@export_subgroup("MODULATION")
@export var base_modulate: Color = Color(.3,.3,.3,1)
@export var hover_modulate: Color = Color(0.5,0.5,0.5,1)	
@export var aquired_modulate: Color = Color(.9,.9,.9,1)
func apply_hover_modulate():
	if modulate == aquired_modulate: return # already aquired return
	modulate = hover_modulate
func apply_base_modulate():
	if Save.data.has(aquired_key): modulate = aquired_modulate
	else: modulate = base_modulate
@export_subgroup("TWEENS")
@export var hover_scale: Vector2 = Vector2(1.2, 1.2)
@export var normal_scale: Vector2 = Vector2(1, 1)
@export var scale_duration: float = 0.15
func tween_scale_up_on_hover():
	var t = create_tween()
	t.tween_property(self, "scale", hover_scale, scale_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
func tween_scale_down_on_exit():
	var t = create_tween()
	t.tween_property(self, "scale", normal_scale, scale_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

@export_group("AUDIO") ## All skills can use the same audio players for ease of use
@export var sfx_bought: AudioStreamPlayer ## Sound to be played when bought. Multiple skills can share same same player
@export var sfx_insufficient: AudioStreamPlayer ## Sound to be played when declined. Automatically referenced if player is sibling
@export var sfx_hover: AudioStreamPlayer ## Sound to be played when hovered. Automatically searches for sibling player
var aquired_key
var prerequisite_key

func hovered():
	if sfx_hover: sfx_hover.play()
	for n in get_tree().get_nodes_in_group(cost_group): n.text = str(cost)
	for n in get_tree().get_nodes_in_group(description_group): n.text = description

func _ready():
	if not sfx_bought: sfx_bought = get_parent().get_node_or_null("Sufficient")
	if not sfx_insufficient: sfx_insufficient = get_parent().get_node_or_null("Insufficient")
	if not sfx_hover: sfx_hover = get_parent().get_node_or_null("Hover")

	if save_key: aquired_key = save_key
	else: aquired_key = Save.get_unique_key(self,"skill_node")
	if prerequisite_node: 
		prerequisite_key = Save.get_unique_key(prerequisite_node, "skill_node")
		if prerequisite_node.save_key != "": prerequisite_key = prerequisite_node.save_key

	
	pressed.connect(_on_pressed)
	mouse_entered.connect(hovered)
	mouse_entered.connect(tween_scale_up_on_hover)
	mouse_exited.connect(tween_scale_down_on_exit)

	apply_base_modulate()
	mouse_entered.connect(apply_hover_modulate)
	mouse_exited.connect(apply_base_modulate)
	Save.save_data_updated.connect(apply_base_modulate)
	
func _on_pressed():

	if not Save.data.has(currency_key): 
		Save.data[currency_key] = 0
	
	if prerequisite_node and not Save.data.has(prerequisite_key):
		if sfx_insufficient: sfx_insufficient.play()
		return
		
	if 	Save.data[currency_key] < cost:
		if sfx_insufficient: sfx_insufficient.play()
		return
	
	if Save.data.has(aquired_key): return
	
	Save.data[currency_key] -= cost
	Save.data[upgrade_key] = new_amount
	#print('upgraded ', upgrade_key, " ", new_amount)
	
	if sfx_bought: sfx_bought.play()
	
	Save.data[aquired_key] = true
	modulate = aquired_modulate
	Save.save_game()
