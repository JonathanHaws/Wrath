extends Node
@export var group = ""
@export var damage = 1
@export var damage_spread := 0
@export var hurt_animation := "HURT" 
@export var death_animation := "DEATH"
@export var show_damage_numbers = false

# For Body / Child Nodes which have to reposition themselves (Matching Animations, Hurt Particles)
func teleport_nodes(body: Node3D) -> void:
	for node in [body] + body.get_children():
		if node.is_in_group("teleport_to_attacking_area"):
			#print('getting here')
			node.global_position = self.global_position

# To trigger animation body receving damage needs to have an animation player as a direct shallow child
func try_to_trigger_animation(node: Node, animation_name: String) -> void:
	for child in node.get_children():
		if not (child is AnimationPlayer): continue
		if not child.has_animation(animation_name): continue
		if child.current_animation == animation_name: continue
		child.play(animation_name)

func _on_body_entered(body)-> void: 
	if group != "" and body.is_in_group(group): return

	if not "HEALTH" in body: return
	
	var final_damage = damage + randi_range(-damage_spread, damage_spread)
	body.HEALTH -= final_damage
	
	teleport_nodes(body)
	
	if show_damage_numbers:
		WorldUI.show_symbol(self.global_position, 140.0, "Node2D/Label", final_damage)
	
	if body.HEALTH > 0: 
		try_to_trigger_animation(body, hurt_animation)
	else:
		try_to_trigger_animation(body, death_animation)			
		
func _ready() -> void:
	if has_signal("body_entered") and not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
