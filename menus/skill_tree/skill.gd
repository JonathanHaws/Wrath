extends TextureButton
@export var cost := 5
@export var currency_key: String = "wisp"

@export var custom_aquired_key: String ## Special save data key to read if this has been aquired yet.
@export var preeq_node: Node

@export var upgrade_key: String = "health" ## The save key to update 
@export var new_amount: Variant = 1.0

@export_subgroup("VISUALS")
@export var cost_group:= "cost_skilltree" ## Label to update with cost of current skill node hovered
@export var aquired_modulate: Color = Color(1,1,1,1)
@export var unaquired_modulate: Color = Color(.3,.3,.3,0.6)
#@export var hover_modulate: Color = Color(0.0,0.0,0.0,.0) ## default color is no hover modulation
@export var hover_modulate: Color = Color(0.1,0.1,0.1,.1)	
@export var disable_hover_modulate := false

@export_subgroup("AUDIO")
@export var sfx_bought: AudioStreamPlayer
@export var sfx_insufficient: AudioStreamPlayer 

var aquired_key
var preeq_key

func _ready():
	sfx_bought = get_node_or_null("../Sufficient")
	sfx_insufficient = get_node_or_null("../Insufficient")

	if custom_aquired_key: aquired_key = custom_aquired_key
	else: aquired_key = Save.get_unique_key(self,"skill_node")
	
	if preeq_node: preeq_key = Save.get_unique_key(preeq_node, "skill_node")
	
	pressed.connect(_on_pressed)
	mouse_entered.connect(func(): 
		for n in get_tree().get_nodes_in_group(cost_group): 
			n.text = "COST: "+ str(cost)
			)
	
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
