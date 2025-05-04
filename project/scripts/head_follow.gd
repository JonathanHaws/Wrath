extends BoneAttachment3D
@export var target = Node
@export var influence_multiplier = 1
@export var turn_speed = 1
@export var range_horizontal = 180
@export var range_vertical = 10
@export var local_axis: Vector3 = Vector3.UP

func _process(delta: float) -> void:
	if not target: return
	var skel := get_parent() as Skeleton3D
	var idx := skel.find_bone(bone_name)
	if idx < 0: return
	
	#var bone_pose := skel.get_bone_global_pose(idx)
	#bone_pose.basis = bone_pose.basis.rotated(Vector3.UP, deg2rad(.2* delta))
	#skel.set_bone_global_pose_override(idx, bone_pose, 1.0, true)
	
	#var pose := skel.get_bone_global_pose(idx)
	#skel.set_bone_global_pose_override(idx, pose.rotated(Vector3.UP, 0.01), 1.0, true)
	
	var pose := skel.get_bone_global_pose(idx)
	pose.basis = pose.basis.rotated(pose.basis * local_axis.normalized(), 0.01)
	skel.set_bone_global_pose_override(idx, pose, 1.0, true)
