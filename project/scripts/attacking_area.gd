extends Node
@export var damage = 1
@export var exclusion_group = ""

func _on_body_entered(body)-> void: #print("testing registering")
	if exclusion_group != "" and body.is_in_group(exclusion_group): return
	if "health" in body: body.health -= damage
	if "hurt" in body: body.hurt(damage)
