extends Control
@export var speed := 1.0
@export var min_zoom := 0.5
@export var max_zoom := 1.5
@export var required_node: Control ## Specifies the region which must always be visible. To avoid players losing the region they wanna check
var zoom := 1.0
var last_mouse_pos := Vector2.ZERO

func clamp_required_node():
	if not required_node: return
	var vp := get_viewport_rect().size
	var rect := required_node.get_global_rect()
	var dx := 0.0
	var dy := 0.0
	if rect.position.x > vp.x: dx = vp.x - rect.position.x
	if rect.position.x + rect.size.x < 0: dx = - (rect.position.x + rect.size.x)
	if rect.position.y > vp.y: dy = vp.y - rect.position.y
	if rect.position.y + rect.size.y < 0: dy = - (rect.position.y + rect.size.y)
	position += Vector2(dx, dy)

func center_required_node():
	if not required_node: return
	var vp := get_viewport_rect().size
	var rect := required_node.get_global_rect()
	var target_pos := vp * 0.5 - rect.size * 0.5
	var offset := target_pos - rect.position
	position += offset


func get_mouse_local() -> Vector2:
	return (get_viewport().get_mouse_position() - global_position) / zoom

func adjust_zoom(factor):
	var mouse_before = get_mouse_local()

	zoom *= factor
	zoom = clamp(zoom, min_zoom, max_zoom)
	scale = Vector2.ONE * zoom

	var mouse_after = get_mouse_local()
	position += (mouse_after - mouse_before) * zoom

func _process(_delta):
	if is_visible_in_tree():
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		center_required_node()
	
	var move := Vector2.ZERO
	if Input.is_action_pressed("ui_up"): move.y -= speed
	if Input.is_action_pressed("ui_down"): move.y += speed
	if Input.is_action_pressed("ui_left"): move.x -= speed
	if Input.is_action_pressed("ui_right"): move.x += speed
	position += move

	if Input.is_action_just_released("zoom_in"):
		adjust_zoom(1.1)
	elif Input.is_action_just_released("zoom_out"):
		adjust_zoom(0.9)

	if Input.is_action_pressed("pan"):
		position += (get_mouse_local() - last_mouse_pos) * zoom

	last_mouse_pos = get_mouse_local()
	
	clamp_required_node()
