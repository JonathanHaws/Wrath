extends Node3D
@export var target = Node
@export var skeleton : Node
@export var bone_name : String
#@export var offset = Vector3(0, 1, 0) 
#@export var influence_multiplier = .5
#@export var turn_speed = .23

#made sure node 3d is not parented to skeleton in any way to avoid async updating of transform confusion
var up_vector: Vector3
	
func _process(delta: float) -> void:
	if not target: return
	if not skeleton: return
	
	var bone = skeleton.find_bone(bone_name)
	var pose = skeleton.get_bone_global_pose(bone)
	
	global_transform.origin = skeleton.global_transform * pose.origin

	look_at(target.global_position, Vector3.UP, true)
	
	var new_rotation = Quaternion.from_euler(Vector3(rotation))
	skeleton.set_bone_pose_rotation(bone, new_rotation)


	
	
