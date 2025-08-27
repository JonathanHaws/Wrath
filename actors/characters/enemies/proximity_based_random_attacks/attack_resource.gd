extends Resource
class_name AttackResource
@export var animation_name: StringName ## Attack to trigger
@export var multiplier: float = 1.0 ## quickly balance only changing a single number
@export var radius: float = 50.0 ## radius of the liklehood curve
@export var likelihood_curve: Curve ## proximit based left being close right far
## For when you want enemy to only attack if player is to the left or to the right
## By default the player doesnt have to be in an area to do this attack
@export var area_multiplier_groups: Array[StringName] = [] 
