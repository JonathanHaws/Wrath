extends Area3D
@export var bounce_force: float = 30.0
@export var bounce_sound: AudioStream

func _on_body_entered(body):
	if "velocity" in body:
		body.velocity.y = bounce_force
		Squash.squish(.5, $MeshInstance3D)
		Audio.play_2d_sound(bounce_sound, 1, .8)
		SlowMotion.impact(0.1, 0)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))


func _physics_process(_delta: float) -> void:
	Squash.settle($MeshInstance3D, _delta, 0.09, 1)
