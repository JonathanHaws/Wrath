extends MeshInstance3D # Use quad mesh. ALso make sure tranform scale = 1 with different sizes being determined by size
@export var viewport: SubViewport
@export var mirror_camera: Camera3D
@export var pixels_per_world_unit: = 100

func _ready():
	viewport.size = Vector2i(mesh.size * pixels_per_world_unit)
	mirror_camera.projection = Camera3D.PROJECTION_FRUSTUM
	

#make it so that theres a subviewport with a camera
#
#the mirror camera should go reflected transform with frustum... projection with the near being the distance frmo teh mirror camera to the mirror. clipping its side

func reflect_point(point: Vector3, plane_point: Vector3, plane_normal: Vector3) -> Vector3:
	var to_point = point - plane_point
	return point - 2.0 * to_point.dot(plane_normal) * plane_normal

func reflect_direction(dir: Vector3, plane_normal: Vector3) -> Vector3:
	return dir - 2.0 * dir.dot(plane_normal) * plane_normal

func _process(_delta):
	var current_cam: Camera3D= get_viewport().get_camera_3d()
	if current_cam == null: return

	viewport.size = Vector2i(mesh.size * pixels_per_world_unit)
	
	# Transform the mirror camera to the opposite side of the mirror plane
	var MirrorNormal = global_transform.basis.z	
	var MirrorTransform =  Mirror_transform(MirrorNormal, global_transform.origin)
	mirror_camera.global_transform = MirrorTransform * current_cam.global_transform
	
	#Look perpendicular into the mirror plane for frostum camera
	mirror_camera.global_transform = mirror_camera.global_transform.looking_at(
			current_cam.global_transform.origin/2 + mirror_camera.global_transform.origin/2, \
			mirror_camera.global_transform.basis.y
		)
	
	var cam2mirror_offset = global_transform.origin - mirror_camera.global_transform.origin
	var near = abs((cam2mirror_offset).dot(MirrorNormal)) # near plane distance
	near += 0.05 # avoid rendering own surface

	# transform offset to camera's local coordinate system (frostum offset uses local space)
	var cam2mirror_camlocal = mirror_camera.global_transform.basis.inverse() * cam2mirror_offset
	var frostum_offset =  Vector2(cam2mirror_camlocal.x, cam2mirror_camlocal.y)
	var aspect = float(mesh.size.x) / float(mesh.size.y)
	mirror_camera.set_frustum(mesh.size.y, frostum_offset, near, 10000)


func Mirror_transform(n : Vector3, d : Vector3) -> Transform3D:
	var basisX : Vector3 = Vector3(1.0, 0, 0) - 2 * Vector3(n.x * n.x, n.x * n.y, n.x * n.z)
	var basisY : Vector3 = Vector3(0, 1.0, 0) - 2 * Vector3(n.y * n.x, n.y * n.y, n.y * n.z)
	var basisZ : Vector3 = Vector3(0, 0, 1.0) - 2 * Vector3(n.z * n.x, n.z * n.y, n.z * n.z)
	var offset = Vector3.ZERO
	offset = 2 * n.dot(d)*n
	return Transform3D(Basis(basisX, basisY, basisZ), offset)	
