extends CanvasLayer


# Set to true to see the buttons on PC while testing
const DEBUG_ALWAYS_SHOW = false


const MARGIN = 12

var left_btn
var right_btn
var jump_btn
var pause_btn

func _ready():
	left_btn = make_button("move_left", "<", 56, true)
	right_btn = make_button("move_right", ">", 56, true)
	jump_btn = make_button("jump", "JUMP", 72, false)
	pause_btn = make_button("pause", "II", 28, false)

	get_viewport().size_changed.connect(place_buttons)
	place_buttons()

func make_button(action, label_text, btn_size, slide_to_press):
	var btn = TouchScreenButton.new()
	btn.action = action
	btn.passby_press = slide_to_press
	btn.texture_normal = make_texture(btn_size, Color(1, 1, 1, 0.25))
	btn.texture_pressed = make_texture(btn_size, Color(1, 1, 1, 0.55))

	var shape = RectangleShape2D.new()
	shape.size = Vector2(btn_size, btn_size)
	btn.shape = shape
	btn.shape_visible = false

	if DEBUG_ALWAYS_SHOW:
		btn.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
	else:
		btn.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY

	var label = Label.new()
	label.text = label_text
	label.size = Vector2(btn_size, btn_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(label)

	add_child(btn)
	return btn


func make_texture(text_size, color):
	var img = Image.create(text_size, text_size, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


func place_buttons():
	var screen = get_viewport().get_visible_rect().size
	var bottom = screen.y - 56 - MARGIN

	left_btn.position = Vector2(MARGIN, bottom)
	right_btn.position = Vector2(MARGIN * 2 + 56, bottom)
	jump_btn.position = Vector2(screen.x - 72 - MARGIN, screen.y - 72 - MARGIN)
	pause_btn.position = Vector2(screen.x - 28 - MARGIN, 30)
