extends MeshInstance3D # Use quad mesh. ALso make sure tranform scale = 1 with different sizes being determined by size
@export var viewport: SubViewport
@export var mirror_camera: Camera3D
@export var pixels_per_world_unit: = 100

func _ready():
	viewport.size = Vector2i(mesh.size * pixels_per_world_unit)
	mirror_camera.projection = Camera3D.PROJECTION_FRUSTUM

func _process(_delta):
	var current_cam: Camera3D= get_viewport().get_camera_3d()
	if current_cam == null: return

	if viewport.world_3d == null: viewport.world_3d = World3D.new()
	viewport.world_3d = get_viewport().world_3d
	viewport.size = Vector2i(mesh.size * pixels_per_world_unit)
	
	# Transform the mirror camera to the opposite side of the mirror plane
	var MirrorNormal = global_transform.basis.z	
	var MirrorTransform =  MirrorTransform()
	mirror_camera.global_transform = MirrorTransform * current_cam.global_transform
	
	#Look perpendicular into the mirror plane for frostum camera
	mirror_camera.global_transform = mirror_camera.global_transform.looking_at(
		mirror_camera.global_transform.origin + global_transform.basis.z.normalized(),
		global_transform.basis.y.normalized()
	)
	
	var cam2mirror_offset = global_transform.origin - mirror_camera.global_transform.origin
	var near = abs((cam2mirror_offset).dot(MirrorNormal)) # near plane distance
	near += 0.05 # avoid rendering own surface

	# transform offset to camera's local coordinate system (frostum offset uses local space)
	var cam2mirror_camlocal = mirror_camera.global_transform.basis.inverse() * cam2mirror_offset
	var frostum_offset =  Vector2(cam2mirror_camlocal.x, cam2mirror_camlocal.y)
	mirror_camera.keep_aspect = Camera3D.KEEP_HEIGHT 
	mirror_camera.set_frustum(mesh.size.y, frostum_offset, near, 10000) 

## Returns a transform that reflects positions and rotations across the mirror plane
func MirrorTransform(normal: Vector3 = global_transform.basis.z, point_on_plane: Vector3 = global_transform.origin) -> Transform3D:
	var basisX: Vector3 = Vector3(1.0, 0, 0) - 2 * Vector3(normal.x * normal.x, normal.x * normal.y, normal.x * normal.z)
	var basisY: Vector3 = Vector3(0, 1.0, 0) - 2 * Vector3(normal.y * normal.x, normal.y * normal.y, normal.y * normal.z)
	var basisZ: Vector3 = Vector3(0, 0, 1.0) - 2 * Vector3(normal.z * normal.x, normal.z * normal.y, normal.z * normal.z)
	var offset: Vector3 = 2.0 * normal.dot(point_on_plane) * normal
	return Transform3D(Basis(basisX, basisY, basisZ), offset)

func get_plane_intersection_blend(from: Vector3, to: Vector3, plane_normal: Vector3 = global_transform.basis.z, plane_point: Vector3 = global_transform.origin) -> float:
	var dir: Vector3 = to - from
	var denom: float = dir.dot(plane_normal)
	if abs(denom) < 0.00001: return 0.0
	return (plane_point - from).dot(plane_normal) / denom

func set_bool_on_shader(group: String = "lut_overlay", property_name: String = "flip_x", value: bool = true) -> void:
	var nodes = get_tree().get_nodes_in_group(group)
	for node in nodes:
		var mat: ShaderMaterial = null
		if node is MeshInstance3D: mat = node.get_active_material(0) as ShaderMaterial
		elif node is Sprite2D: mat = node.material as ShaderMaterial
		elif node is CanvasItem: mat = node.material as ShaderMaterial	
		if not mat: continue
		mat.set_shader_parameter(property_name, value)

func seamless_mirror_camera_transition(duration: float = 1.5, target_camera_group: String = "inside_mirror_camera", 	offset: float = 0.1) -> void:
	
	#var skipper = get_tree().get_first_node_in_group("skipper")
	#if skipper and skipper.disable_camera_transitions:return
	
	#   Current Cam 
	#        ●      
	#         \     
	#          \   
	#           ● 
	# ========================== Mirror Plane
	#           ● 
	#          /
	#         /
	#        ● 
	#    Target Cam
	
	var current_camera: Camera3D = get_viewport().get_camera_3d()
	var target_camera: Camera3D = get_tree().get_first_node_in_group(target_camera_group) as Camera3D
	if current_camera == null or target_camera == null: return
	
	# print out for animation
	var reflected_current_transform: Transform3D = MirrorTransform() * current_camera.global_transform
	var euler := reflected_current_transform.basis.get_euler()
	print("Reflected Target Position: ", reflected_current_transform.origin)
	print("Reflected Rotation: ", Vector3(rad_to_deg(euler.x), rad_to_deg(euler.y), rad_to_deg(euler.z)))
	
	set_bool_on_shader("lut_overlay", "flip_x", false)
	target_camera.current = true
	target_camera.make_current()
	
