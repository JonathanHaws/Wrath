extends Node3D
@export var ANIM: AnimationPlayer
@export var ENTER_AREA: Area3D
@export var EXIT_AREA: Area3D
@export var target_group: String = "player"
var inside = false
var queued_free = false

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(target_group): return
	if inside == true: return
	inside = true
	if ANIM: ANIM.queue("ENTERED")
	
func _on_body_exited(body: Node) -> void:
	if not body.is_in_group(target_group): return
	if inside == false: return
	inside = false
	if ANIM: ANIM.queue("EXITED")
	
func _on_animation_finished(_animation_name):
	if ANIM.get_queue().size() == 0 and queued_free:
		queue_free() 

func _connect_exit_queue_free() -> void:
	if ANIM: ANIM.queue("EXITED")
	if ANIM:
		ANIM.queue("EXITED")
		if not ANIM.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
			ANIM.connect("animation_finished", Callable(self, "_on_animation_finished"))
			queued_free = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ENTER_AREA: ENTER_AREA.connect("body_entered", Callable(self, "_on_body_entered"))
	if EXIT_AREA: EXIT_AREA.connect("body_exited", Callable(self, "_on_body_exited"))
