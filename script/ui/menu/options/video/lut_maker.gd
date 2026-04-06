extends ColorRect
var original_lut: ImageTexture      # the loaded LUT, never changed
var lut: ImageTexture               # the editable LUT
var lut_width: int = 17
var lut_height: int = 17
var lut_depth: int = 17
var textureRect
var control_panel: VBoxContainer # delete 
var tones: VBoxContainer

func make_passthrough_lut_image_texture(width:int, height:int, depth:int) -> ImageTexture:
	var image := Image.create(width * depth, height, false, Image.FORMAT_RGB8)
	for z in range(depth):
		for y in range(height):
			for x in range(width):
				var r:float = float(x) / float(width - 1)
				var g:float = float(y) / float(height - 1)
				var b:float = float(z) / float(depth - 1)
				image.set_pixel(x + z * width, y, Color(r, g, b))
	return ImageTexture.create_from_image(image)

func get_texture_3d_from_image(image: Image, width:int, height:int, depth:int) -> ImageTexture3D:
	var images: Array = []
	for z in range(depth):
		var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
		for y in range(height):
			for x in range(width):
				img.set_pixel(x, y, image.get_pixel(x + z * width, y))
		images.append(img)
	#print(images.size())	
		
	var tex3d := ImageTexture3D.new()
	tex3d.create(Image.FORMAT_RGBA8, width, height, depth, false, images)
	return tex3d
	
func update_lut():
	var img = original_lut.get_image()

	for z in range(lut_depth):
		for y in range(lut_height):
			for x in range(lut_width):
				var c = img.get_pixel(x + z * lut_width, y)
				var shadows = get_tone_vector("Shadows")
				var midtones = get_tone_vector("Midtones")
				var highlights = get_tone_vector("Highlights")
				var t = (c.r + c.g + c.b)/3.0
				var adj = shadows*(1-t) + midtones*0.5 + highlights*t
				c.r = clamp(c.r+adj.x,0,1)
				c.g = clamp(c.g+adj.y,0,1)
				c.b = clamp(c.b+adj.z,0,1)
				img.set_pixel(x + z * lut_width, y, c)

	lut.create_from_image(img)
	textureRect.texture = lut

	if material:
		var tex3d = get_texture_3d_from_image(img, lut_width, lut_height, lut_depth)
		material.set_shader_parameter("default_texture", tex3d)
		material.set_shader_parameter("blend", 0.0)

func create_control_panel() -> VBoxContainer:
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

	var apply_button = Button.new()
	hbox.add_child(apply_button)
	apply_button.text = "RESET"
	return vbox
	

func get_tone_vector(tone_name: String) -> Vector3:
	var vbox = tones.get_node(tone_name + "/VBoxContainer")
	return Vector3(
		vbox.get_node("HBoxContainer/R").value,
		vbox.get_node("HBoxContainer2/G").value,
		vbox.get_node("HBoxContainer3/B").value
	)

func create_tone_folders() -> VBoxContainer:
	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.name = "Tones"
	
	for tone in ["Shadows", "Midtones", "Highlights"]:
		var folder: FoldableContainer = FoldableContainer.new()
		folder.title = tone
		folder.folded = true
		main_vbox.add_child(folder)
		
		var tone_vbox: VBoxContainer = VBoxContainer.new()
		tone_vbox.name = "VBoxContainer"
		
		folder.add_child(tone_vbox)
		folder.name = tone
		
		for channel in ["R", "G", "B"]:
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

	return main_vbox

func create_ui():
	control_panel = create_control_panel()
	tones = create_tone_folders()

	var root = Control.new()
	add_child(root)

	root.anchor_left = 1
	root.anchor_right = 1
	root.anchor_top = 0
	root.anchor_bottom = 0
	root.offset_left = -300   # panel width
	root.offset_top = 0

	var container = VBoxContainer.new()
	root.add_child(container)

	container.add_child(control_panel)
	container.add_child(tones)

func _ready():
	original_lut = make_passthrough_lut_image_texture(lut_width, lut_height, lut_depth)
	lut = original_lut
	create_ui()
	update_lut()

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
	update_lut()


		
