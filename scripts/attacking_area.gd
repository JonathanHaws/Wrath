extends Node
@export var damage = 1
@export var damage_spread := 0
@export var group = ""

func _on_body_entered(body)-> void: 
	if group != "" and body.is_in_group(group): return
	var final_damage = damage + randi_range(-damage_spread, damage_spread)
	if "health" in body: body.health -= final_damage 
	elif "HEALTH" in body: body.HEALTH -= final_damage 
	if "hurt" in body:
		var arg_count = body.get_method_argument_count("hurt")
		if arg_count >= 3:
			body.call("hurt", final_damage, group, self.global_position)
		elif arg_count == 2:
			body.call("hurt", final_damage, group)
		elif arg_count == 1:
			body.call("hurt", final_damage)

func _ready() -> void:
	if has_signal("body_entered") and not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
