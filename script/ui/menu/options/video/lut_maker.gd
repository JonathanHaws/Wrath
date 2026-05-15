extends ColorRect        
@export var dynamic_ui_control: Control ## The control in which dynamic ui will be spawned under
var textureRect
var tones: VBoxContainer

var lut_size: Vector3i = Vector3i(17,17,17)
var original_lut: ImageTexture      
var lut: ImageTexture   

func make_passthrough_lut_image_texture(lut_size: Vector3i) -> ImageTexture:
	var image := Image.create(lut_size.x * lut_size.z, lut_size.y, false, Image.FORMAT_RGB8)
	for z in range(lut_size.z):
		for y in range(lut_size.y):
			for x in range(lut_size.x):
				image.set_pixel(x + z * lut_size.x, y, Color(x / float(lut_size.x - 1), y / float(lut_size.y - 1), z / float(lut_size.z - 1)))
	return ImageTexture.create_from_image(image)

func oklab_to_rgb(lab: Vector3) -> Color:
	var l = lab.x
	var a = lab.y
	var b = lab.z

	var l_ = l + 0.3963377774 * a + 0.2158037573 * b
	var m_ = l - 0.1055613458 * a - 0.0638541728 * b
	var s_ = l - 0.0894841775 * a - 1.2914855480 * b

	l_ = l_ * l_ * l_
	m_ = m_ * m_ * m_
	s_ = s_ * s_ * s_

	var r = 4.0767416621 * l_ - 3.3077115913 * m_ + 0.2309699292 * s_
	var g = -1.2684380046 * l_ + 2.6097574011 * m_ - 0.3413193965 * s_
	var b_ = -0.0041960863 * l_ - 0.7034186147 * m_ + 1.7076147010 * s_

	return Color(r, g, b_)

func reset_adjustments():
	pass

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

	for z in range(lut_size.z):
		for y in range(lut_size.y):
			for x in range(lut_size.x):
				var color = Color(
					x / float(lut_size.x - 1),
					y / float(lut_size.y - 1),
					z / float(lut_size.z - 1)
				)
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
		var tone_hbox := HBoxContainer.new()
		tone_hbox.name = tone
		tones.add_child(tone_hbox)

		var label := Label.new()
		label.text = tone
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tone_hbox.add_child(label)

		var color_picker := ColorPickerButton.new()
		color_picker.color = Color(0, 0, 0)
		color_picker.custom_minimum_size = Vector2(160, 32)
		color_picker.color_changed.connect(func(_c): update_lut())
		tone_hbox.add_child(color_picker)
		
	container.add_child(tones)
	
	#endregion
	
	
	#endregion
	
	update_lut()
