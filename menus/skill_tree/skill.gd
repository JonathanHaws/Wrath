extends TextureButton
@export var cost := 5 ## Price for upgrading 
@export var currency_key: String = "wisp" 
@export var upgrade_key: String = "health" ## The save key to update 
@export var new_amount: Variant = 1.0 ## The update value for the property
@export var custom_aquired_key: String ## Special save data key to read if this has been aquired yet. Thats not just prefixed with node branch
@export var preeq_node: Node ## The node that must be aquired before this one can be purchased. (Previous node skill tree) 

@export_subgroup("VISUALS")
@export var cost_group:= "cost_skilltree" ## Label to update with cost of current skill node hovered
@export var description_group := "ability_info_skilltree" ## Label to update with a description of the ability
@export var description := "Increases players power"
@export var aquired_modulate: Color = Color(1,1,1,1)
@export var unaquired_modulate: Color = Color(.3,.3,.3,0.6)
@export var hover_modulate: Color = Color(0.1,0.1,0.1,.1)	
@export var disable_hover_modulate := false
#@export var hover_modulate: Color = Color(0.0,0.0,0.0,.0) ## default color is no hover modulation

@export_subgroup("AUDIO") ## All skills can use the same audio players for ease of use
@export var sfx_bought: AudioStreamPlayer ## Sound to be played when bought. Multiple skills can share same same player
@export var sfx_insufficient: AudioStreamPlayer ## Sound to be played when declined. Automatically referenced if player is sibling
@export var sfx_hover: AudioStreamPlayer ## Sound to be played when hovered. Automatically searches for sibling player
var aquired_key
var preeq_key

func hovered():
	if sfx_hover: sfx_hover.play()
	for n in get_tree().get_nodes_in_group(cost_group): n.text = str(cost)
	for n in get_tree().get_nodes_in_group(description_group): n.text = description

func _ready():
	if not sfx_bought: sfx_bought = get_parent().get_node_or_null("Sufficient")
	if not sfx_insufficient: sfx_insufficient = get_parent().get_node_or_null("Insufficient")
	if not sfx_hover: sfx_hover = get_parent().get_node_or_null("Hover")

	if custom_aquired_key: aquired_key = custom_aquired_key
	else: aquired_key = Save.get_unique_key(self,"skill_node")
	
	if preeq_node: preeq_key = Save.get_unique_key(preeq_node, "skill_node")
	
	pressed.connect(_on_pressed)
	mouse_entered.connect(hovered)
	
	if Save.data.has(aquired_key):
		modulate = aquired_modulate
	else:
		modulate = unaquired_modulate
	
	if not disable_hover_modulate:
		mouse_entered.connect(func(): modulate += hover_modulate)
		mouse_exited.connect(func(): modulate -= hover_modulate)
	
func _on_pressed():
	if not Save.data.has(currency_key): return
	if preeq_node and not Save.data.has(preeq_key):
		if sfx_insufficient: sfx_insufficient.play()
		return
	
	if Save.data.has(aquired_key): return
	
	if Save.data[currency_key] < cost:
		if sfx_insufficient: sfx_insufficient.play()
		return
		
	Save.data[currency_key] -= cost
	Save.data[upgrade_key] = new_amount
	#print('upgraded ', upgrade_key, " ", new_amount)
	
	if sfx_bought: sfx_bought.play()
	
	Save.data[aquired_key] = true
	modulate = aquired_modulate
