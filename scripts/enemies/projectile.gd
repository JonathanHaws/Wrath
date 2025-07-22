extends Node3D
@export var speed = 15.0
@export var destroy_area: Area3D
@export var exclude_groups: Array[String] = []

func _ready():
	if destroy_area:
		destroy_area.body_entered.connect(_on_body_entered)

func _process(delta):
	translate(Vector3.FORWARD * speed * delta)

func _on_body_entered(body: Node) -> void:
	for group in exclude_groups:
		if body.is_in_group(group): return
	queue_free()
