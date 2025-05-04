extends BoneAttachment3D
@export var target = Node
@export var influence_multiplier = .5
@export var turn_speed = 1
@export var range_horizontal = 45
@export var range_vertical = 10
var initial_rotation: Quaternion
@export var use_model_front = false
var initial_transform: Transform3D

func _ready() -> void:
	#initial_rotation = global_transform.basis.get_rotation_quaternion()
	#initial_transform = transform
	override_pose = false
	pass
	
func _process(delta: float) -> void:
	if not target: return
	#offset it at the start of the frame
	
	
	look_at(target.global_position,Vector3(0,1,0),use_model_front)
	
	var skel := get_parent() as Skeleton3D
	var idx := skel.find_bone(bone_name)
	if idx < 0: return
	
	var bone = skel.get_bone_global_pose(idx) 
	
	var direction = (target.global_position - global_position).normalized()
	bone.basis = Basis().looking_at(direction, Vector3.UP)
	
	skel.set_bone_global_pose(idx, bone)

	



	#var euler: Vector3 = global_transform.basis.get_rotation_quaternion().get_euler() * rad_to_deg(1)
	#print(euler)
	#var clamped_y_rotation = clamp(euler.y, -range_horizontal, range_horizontal)
	#
	#var new_rot = Quaternion(Vector3(0, 1, 0), deg_to_rad(clamped_y_rotation))
	#global_transform.basis = Basis(new_rot)
	
	
	
	
	
	#rotate_x(deg_to_rad(rotation_offset.x))
	#rotate_y(deg_to_rad(rotation_offset.y))
	#rotate_z(deg_to_rad(rotation_offset.z))
	
	#var skel := get_parent() as Skeleton3D
	#var idx := skel.find_bone(bone_name)
	#if idx < 0: return
	#var pose := skel.get_bone_global_pose(idx)
	#var to_target = target.global_position - get_parent().get_bone_global_pose(skel.find_bone(bone_name)).origin
	##print(to_target)
	#
	#look_at(target.global_position)
	#
	#pose.basis = pose.basis.looking_at(to_target.normalized(), local_axis.normalized())
	#skel.set_bone_global_pose_override(idx, pose, 1.0, true)

				
	
