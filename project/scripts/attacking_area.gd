extends Node
@export var damage = 1
@export var group = ""

func _on_body_entered(body)-> void: 
	if group != "" and body.is_in_group(group): return
	if "health" in body: body.health -= damage
	if "hurt" in body:
		var arg_count = body.get_method_argument_count("hurt")
		if arg_count >= 3:
			body.call("hurt", damage, group, self.global_position)
		elif arg_count == 2:
			body.call("hurt", damage, group)
		elif arg_count == 1:
			body.call("hurt", damage)
