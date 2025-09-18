extends Area3D
@export var PLAYER_GROUP: String = "player_body"
@export var PLAYER_ANIM_GROUP: String = "player_anim"
@export var climb_speed: float = 200.0
var on_ladder: bool = false
var player: Node = null
var ladder_position: Vector3
var anim: AnimationPlayer

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player_body"):
		on_ladder = true
		player = body
		ladder_position = body.global_position
		
		var players = get_tree().get_nodes_in_group(PLAYER_ANIM_GROUP)
		if players.size() > 0:
			anim = players[0]
			anim.play("LADDER_ENTER")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(PLAYER_GROUP):
		on_ladder = false
		player = null
		if anim: 
			anim.speed_scale = 1
			anim.play("LADDER_EXIT")
		
func player_still_on_ladder(player_node: Node, new_position: Vector3) -> bool:
	var temp_transform = player_node.global_transform
	temp_transform.origin = new_position
	for body in get_overlapping_bodies():
		if body == player_node:
			return true
	return false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if on_ladder and player and "velocity" in player:
		player.velocity = Vector3.ZERO

		var ladder_up = global_transform.basis.y.normalized()
		var ladder_right = global_transform.basis.z.normalized()

		var anim_scale := 0.0

		if Input.is_action_pressed("keyboard_forward"):
			player.velocity += ladder_up * climb_speed * delta
			anim_scale = 1.0
		if Input.is_action_pressed("keyboard_back"):
			player.velocity -= ladder_up * climb_speed * delta
			anim_scale = 1
		if Input.is_action_pressed("keyboard_left"):
			player.velocity += ladder_right * climb_speed * delta
			anim_scale = 1.0
		if Input.is_action_pressed("keyboard_right"):
			player.velocity -= ladder_right * climb_speed * delta
			anim_scale = 1.0

		if anim and not anim.current_animation in ["LADDER_ENTER","LADDER_EXIT"]:
			if anim_scale == 0: anim.stop(true)
			else: anim.play("LADDER")

		player.move_and_slide()
