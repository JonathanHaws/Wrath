extends Node
@export var key: String
func _ready(): if not Save.data.has(key): Save.data[key] = 0
func increase(): Save.data[key] += 1
