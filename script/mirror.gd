extends MeshInstance3D # Use quad mesh. ALso make sure tranform scale = 1 with different sizes being determined by size
@export var pixels_per_world_unit: = 100
@export var viewport: SubViewport
@export var mirror_camera: Camera3D
@export var outside_transition_camera: Camera3D
@export var inside_transition_camera: Camera3D

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
#   Reflected Mirror Cam

func _ready():
	
	mirror_camera.projection = Camera3D.PROJECTION_FRUSTUM
	mirror_camera.keep_aspect = Camera3D.KEEP_HEIGHT 
	viewport.size = Vector2i(mesh.size * pixels_per_world_unit)


func _process(_delta):
	
	inside_transition_camera.global_transform = MirrorTransform() * outside_transition_camera.global_transform
	
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
	mirror_camera.set_frustum(mesh.size.y, frostum_offset, near, 10000) 

## Returns a transform that reflects positions and rotations across the mirror plane
func MirrorTransform(normal: Vector3 = global_transform.basis.z, point_on_plane: Vector3 = global_transform.origin) -> Transform3D:
	var basisX: Vector3 = Vector3(1.0, 0, 0) - 2 * Vector3(normal.x * normal.x, normal.x * normal.y, normal.x * normal.z)
	var basisY: Vector3 = Vector3(0, 1.0, 0) - 2 * Vector3(normal.y * normal.x, normal.y * normal.y, normal.y * normal.z)
	var basisZ: Vector3 = Vector3(0, 0, 1.0) - 2 * Vector3(normal.z * normal.x, normal.z * normal.y, normal.z * normal.z)
	var offset: Vector3 = 2.0 * normal.dot(point_on_plane) * normal
	return Transform3D(Basis(basisX, basisY, basisZ), offset)
