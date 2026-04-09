extends ColorRect
var lut_size: Vector3i = Vector3i(17,17,17)
var original_lut: ImageTexture      
var lut: ImageTexture              

@export var dynamic_ui_control: Control ## The control in which dynamic ui will be spawned under
var textureRect
var control_panel: VBoxContainer # delete 
var tones: VBoxContainer
func get_tone_vector(tone_name: String) -> Vector4:
	var vbox = tones.get_node(tone_name + "/VBoxContainer")
	return Vector4(
		vbox.get_node("HBoxContainer/S").value,
		vbox.get_node("HBoxContainer2/R").value,
		vbox.get_node("HBoxContainer3/G").value,
		vbox.get_node("HBoxContainer4/B").value
	)
func reset_adjustments():
	pass

func make_passthrough_lut_image_texture(lut_size: Vector3i) -> ImageTexture:
	var image := Image.create(lut_size.x * lut_size.z, lut_size.y, false, Image.FORMAT_RGB8)
	for z in range(lut_size.z):
		for y in range(lut_size.y):
			for x in range(lut_size.x):
				image.set_pixel(x + z * lut_size.x, y, Color(x / float(lut_size.x - 1), y / float(lut_size.y - 1), z / float(lut_size.z - 1)))
	return ImageTexture.create_from_image(image)
func get_texture_3d_from_image(image: Image, width:int, height:int, depth:int) -> ImageTexture3D:
	var images: Array = []
	for z in range(depth):
		var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
		for y in range(height):
			for x in range(width):
				img.set_pixel(x, y, image.get_pixel(x + z * width, y))
		images.append(img)
		
	var tex3d := ImageTexture3D.new()
	tex3d.create(Image.FORMAT_RGBA8, width, height, depth, false, images)
	return tex3d
func update_lut():
	var img = original_lut.get_image()

	for z in range(lut_size.z): for y in range(lut_size.y): for x in range(lut_size.x):
			var color = img.get_pixel(x + z * lut_size.x, y)

			var shadows_vector: Vector4 = get_tone_vector("Shadows")
			var midtones_vector: Vector4 = get_tone_vector("Midtones")
			var highlights_vector: Vector4 = get_tone_vector("Highlights")

			var brightness = (color.r + color.g + color.b) / 3.0

			var adjustment_r = shadows_vector.y * shadows_vector.x * (1.0 - brightness) + midtones_vector.y * midtones_vector.x * 0.5 + highlights_vector.y * highlights_vector.x * brightness
			var adjustment_g = shadows_vector.z * shadows_vector.x * (1.0 - brightness) + midtones_vector.z * midtones_vector.x * 0.5 + highlights_vector.z * highlights_vector.x * brightness
			var adjustment_b = shadows_vector.w * shadows_vector.x * (1.0 - brightness) + midtones_vector.w * midtones_vector.x * 0.5 + highlights_vector.w * highlights_vector.x * brightness

			color.r = clamp(color.r + adjustment_r, 0, 1)
			color.g = clamp(color.g + adjustment_g, 0, 1)
			color.b = clamp(color.b + adjustment_b, 0, 1)

			var mapped: float = curve_rgb.sample(brightness)
			var scale: float = mapped / max(brightness, 0.0001)

			color.r = clamp(color.r * scale, 0.0, 1.0)
			color.g = clamp(color.g * scale, 0.0, 1.0)
			color.b = clamp(color.b * scale, 0.0, 1.0)

			img.set_pixel(x + z * lut_size.x, y, color)

	lut.create_from_image(img)
	textureRect.texture = lut

	if material:
		var tex3d = get_texture_3d_from_image(img, lut_size.x, lut_size.y, lut_size.z)
		material.set_shader_parameter("default_texture", tex3d)
		material.set_shader_parameter("blend", 0.0)

func _on_save_pressed():
	var fd := FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.add_filter("*.png ; PNG Image")
	fd.current_file = "lut.png"	# default name
	add_child(fd)
	fd.connect("file_selected", Callable(self, "_on_save_selected"))
	fd.popup_centered()
func _on_save_selected(path: String):
	var image: Image = lut.get_image()
	image.save_png(path)
	#print("Saved LUT to: " + path)
func _on_load_pressed():
	var fd := FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE  
	fd.access = FileDialog.ACCESS_RESOURCES       
	fd.add_filter("*.png ; PNG Image")             
	add_child(fd)
	fd.connect("file_selected", Callable(self, "_on_load_selected"))
	fd.popup_centered()
	fd.set_current_dir("res://textures/lut/")
func _on_load_selected(path: String):
	var image = Image.load_from_file(path)       # must be a real file path
	original_lut = ImageTexture.create_from_image(image)
	lut = original_lut
	textureRect.texture = lut
	reset_adjustments()
	
	update_lut()

@export var curve_rgb: Curve = Curve.new()
var curve_background: ColorRect
var curve_line: Line2D
var selected_point: Control
func _create_curve_point(index: int) -> ColorRect:
	var point_rect := ColorRect.new()
	point_rect.color = Color(1, 1, 1)
	point_rect.custom_minimum_size = Vector2(10, 10)
	point_rect.gui_input.connect(Callable(self, "_on_point_gui_input").bind(point_rect))
	return point_rect
func _update_curve(width: int = 300, height: int = 300):
	var new_points = []
	for i in range(width):
		var t = float(i) / float(width - 1)
		new_points.append(Vector2(i, height - curve_rgb.sample(t) * height))
	curve_line.points = new_points  # safer than clear + add_point

	# Update point handles
	var curve_points = curve_line.get_children()
	for i in range(curve_rgb.get_point_count()):
		var pt = curve_rgb.get_point_position(i)
		var px = pt.x * width - 5
		var py = height - pt.y * height - 5
		curve_points[i].position = Vector2(px, py)
func _on_point_gui_input(event: InputEvent, point_node: Control):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if selected_point: return
				selected_point = point_node
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				var i = curve_line.get_children().find(point_node)
				if i != -1:
					curve_rgb.remove_point(i)
					point_node.queue_free()
					_update_curve()
				selected_point = null
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				selected_point = null
	elif event is InputEventMouseMotion and selected_point == point_node:
		var local_pos = curve_background.get_local_mouse_position()
		var t = clamp(local_pos.x / curve_background.size.x, 0, 1)
		var v = clamp(1.0 - local_pos.y / curve_background.size.y, 0, 1)
		var i = curve_line.get_children().find(selected_point)
		if i != -1:
			curve_rgb.set_point_offset(i, t)  
			curve_rgb.set_point_value(i, v) 
			_update_curve()
			selected_point = curve_line.get_children()[i]		
func _on_curve_background_input(event: InputEvent):
	pass 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = curve_background.get_local_mouse_position()
		var t = clamp(local_pos.x / curve_background.size.x, 0, 1)
		var v = clamp(1.0 - local_pos.y / curve_background.size.y, 0, 1)
		var index = 0
		while index < curve_rgb.get_point_count() and curve_rgb.get_point_position(index).x < t:
			index += 1
		curve_rgb.add_point(Vector2(t, v), index)
		curve_line.add_child(_create_curve_point(index))
		_update_curve()

func _ready():
	original_lut = make_passthrough_lut_image_texture(lut_size)
	lut = original_lut
	

	#region Create Dynamic UI Controls
	
	#region Create Root Control
	
	var root = Control.new()
	dynamic_ui_control.add_child(root)

	root.anchor_left = 1
	root.anchor_right = 1
	root.anchor_top = 0
	root.anchor_bottom = 0
	root.offset_left = -300 
	root.offset_top = 0
	
	var container = VBoxContainer.new()
	root.add_child(container)
	
	#endregion
	
	#region Create Control Panel
	
	var vbox = VBoxContainer.new()

	textureRect = TextureRect.new()
	vbox.add_child(textureRect)
	textureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	textureRect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textureRect.texture = lut

	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var save_button = Button.new()
	hbox.add_child(save_button)
	save_button.text = "SAVE"
	save_button.pressed.connect(_on_save_pressed)

	var load_button = Button.new()
	hbox.add_child(load_button)
	load_button.text = "LOAD"
	load_button.pressed.connect(_on_load_pressed)

	var reset_button = Button.new()
	hbox.add_child(reset_button)
	reset_button.text = "RESET"
	reset_button.pressed.connect(reset_adjustments)
	
	container.add_child(vbox)
	
	#endregion
		
	#region Create Shadows, Midtones, Highlights Folders
	
	tones = VBoxContainer.new()
	tones.name = "Tones"
	
	for tone in ["Shadows", "Midtones", "Highlights"]:
		var folder: FoldableContainer = FoldableContainer.new()
		folder.title = tone
		folder.folded = true
		tones.add_child(folder)
		
		var tone_vbox: VBoxContainer = VBoxContainer.new()
		tone_vbox.name = "VBoxContainer"
		
		folder.add_child(tone_vbox)
		folder.name = tone
		
		for channel in ["S", "R", "G", "B"]:
			var row: HBoxContainer = HBoxContainer.new()
			tone_vbox.add_child(row)
			row.name = "HBoxContainer"
			
			var label: Label = Label.new()
			label.text = channel
			row.add_child(label)
			
			var slider: HSlider = HSlider.new()
			slider.min_value = -1
			slider.max_value = 1
			slider.step = 0.01
			slider.value = 0
			slider.name = channel
			slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slider.value_changed.connect(func(_val): update_lut())
			row.add_child(slider)
			
			var reset := Button.new()
			reset.text = "@"
			reset.pressed.connect(func(): slider.value = 0)	# inline reset
			row.add_child(reset)	
	
	container.add_child(tones)
	
	#endregion
	
	#region Create Luminosity Curve Adjustments
	
	var folder := FoldableContainer.new()
	folder.title = "Curve"
	folder.folded = true
	
	curve_background = ColorRect.new() 
	curve_background.color = Color(0.1, 0.1, 0.1, 0.431)  
	curve_background.custom_minimum_size = Vector2(300, 300)
	curve_background.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	curve_background.size_flags_vertical = Control.SIZE_EXPAND_FILL
	curve_background.gui_input.connect(_on_curve_background_input)
	folder.add_child(curve_background)

	curve_line = Line2D.new()
	curve_line.width = 2
	curve_line.default_color = Color.LIGHT_GRAY
	curve_background.add_child(curve_line)

	for i in range(curve_rgb.get_point_count()):
		curve_line.add_child(_create_curve_point(i))
		
	_update_curve()
	
	container.add_child(folder)
	#endregion
	
	#endregion
	
	update_lut()
func process():
	pass
	#_update_curve()	
