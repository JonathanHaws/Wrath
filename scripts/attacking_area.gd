extends Node
@export var group = ""
@export var damage = 1
@export var damage_spread := 0
@export var hurt_animation := "HURT" 
@export var death_animation := "DEATH"

#func try_call_method(node: Node, method: String, args: Array) -> bool:
	#if not node.has_method(method): return false
	#args = args.slice(0, node.get_method_argument_count(method))
	#node.callv(method, args)
	#return true

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
	
	if body.HEALTH > 0: 
		try_to_trigger_animation(body, hurt_animation)
	else:
		try_to_trigger_animation(body, death_animation)
			
	#var args = [final_damage, group, self.global_position]
	#if try_call_method(body, "hurt", args): return
	#for child in body.get_children():
		#if child.name == "Hurt" and try_call_method(child, "hurt", args): return	
		
func _ready() -> void:
	if has_signal("body_entered") and not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
