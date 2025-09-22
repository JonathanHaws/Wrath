extends Node
@export var hit_shape: Node
@export var regular_death_animation_player: AnimationPlayer
@export var regular_death_animation_name: StringName = "DEATH"
@export var platforming_death_animation_player: AnimationPlayer
@export var platforming_death_animation_name: StringName = "FALL_DEATH"

func play_animation_based_of_cause_of_death() -> void:
	var hs = hit_shape.last_hurt_shape #hitshape died to
	
	if hs and hs.is_in_group("platforming_hurt_shape"):
		platforming_death_animation_player.play(platforming_death_animation_name)
		platforming_death_animation_player.seek(0, true)
	else:
		regular_death_animation_player.play(regular_death_animation_name)
		regular_death_animation_player.seek(0, true)
