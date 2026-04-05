extends ColorRect
var lut: ImageTexture
var lut_width: int = 17
var lut_height: int = 17
var lut_depth: int = 17
var textureRect

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

	var apply_button = Button.new()
	hbox.add_child(apply_button)
	apply_button.text = "RESET"
	return vbox
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
			slider.value_changed.connect(Callable(self, "_on_slider_changed"))
			row.add_child(slider)

	return main_vbox
func create_ui():
	
	var container = Control.new()
	add_child(container)
	container.anchor_left = .5
	container.anchor_top = 0
	container.anchor_right = 0
	container.anchor_bottom = 0
	container.pivot_offset_ratio = Vector2(1, 0)
	
	control_panel = create_control_panel()
	tones = create_tone_folders()

	var main_vbox = VBoxContainer.new()
	add_child(main_vbox)
	main_vbox.add_child(control_panel)
	main_vbox.add_child(tones)
	
var control_panel: VBoxContainer
var tones: VBoxContainer

func make_passthrough_lut(width:int, height:int, depth:int) -> ImageTexture:
	var image := Image.create(width * depth, height, false, Image.FORMAT_RGB8)
	for z in range(depth):
		for y in range(height):
			for x in range(width):
				var r:float = float(x) / float(width - 1)
				var g:float = float(y) / float(height - 1)
				var b:float = float(z) / float(depth - 1)
				image.set_pixel(x + z * width, y, Color(r, g, b))
	return ImageTexture.create_from_image(image)

func _ready():
	lut = make_passthrough_lut(lut_width, lut_height, lut_depth)
	create_ui()

	#save_button.pressed.connect(_on_save_pressed)

func _on_save_pressed():
	var img := lut.get_image()
	img.save_png("user://lut.png")	# saves file

func _process(_delta):
	if not material: print("No material!"); return
	
	var shadows = Vector3(
		tones.get_node("Shadows/VBoxContainer/HBoxContainer/R").value,
		tones.get_node("Shadows/VBoxContainer/HBoxContainer2/G").value,
		tones.get_node("Shadows/VBoxContainer/HBoxContainer3/B").value
	)
	
	var midtones = Vector3(
		tones.get_node("Midtones/VBoxContainer/HBoxContainer/R").value,
		tones.get_node("Midtones/VBoxContainer/HBoxContainer2/G").value,
		tones.get_node("Midtones/VBoxContainer/HBoxContainer3/B").value
	)
	
	var highlights = Vector3(
		tones.get_node("Highlights/VBoxContainer/HBoxContainer/R").value,
		tones.get_node("Highlights/VBoxContainer/HBoxContainer2/G").value,
		tones.get_node("Highlights/VBoxContainer/HBoxContainer3/B").value
	)
	
	material.set_shader_parameter("shadows", shadows)
	material.set_shader_parameter("midtones", midtones)
	material.set_shader_parameter("highlights", highlights)
	#))
		
