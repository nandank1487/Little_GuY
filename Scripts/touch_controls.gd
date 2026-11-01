extends CanvasLayer

# For testing
const DEBUG_ALWAYS_SHOW = false

const MARGIN = 14
const MOVE_SIZE = 58
const JUMP_SIZE = 78
const PAUSE_SIZE = 30
const BUTTON_GAP = 40       # space between the < and > buttons

const FILL = Color(0.16, 0.14, 0.18, 0.55)
const BORDER = Color(0.9, 0.62, 0.6, 0.9)
const FILL_PRESSED = Color(0.9, 0.62, 0.6, 0.8)
const BORDER_PRESSED = Color(1, 1, 1, 0.95)

var left_btn
var right_btn
var jump_btn
var pause_btn


func _ready():
	var has_touch = DisplayServer.is_touchscreen_available() or OS.has_feature("web_android") or OS.has_feature("web_ios")
	if not has_touch and not DEBUG_ALWAYS_SHOW:
		visible = false
	left_btn = make_button("move_left", "<", MOVE_SIZE, 18, true)
	right_btn = make_button("move_right", ">", MOVE_SIZE, 18, true)
	jump_btn = make_button("jump", "JUMP", JUMP_SIZE, 14, false)
	pause_btn = make_button("pause", "II", PAUSE_SIZE, 10, false)

	get_viewport().size_changed.connect(place_buttons)
	place_buttons()


func make_button(action, label_text, btn_size, font_size, slide_to_press):
	var btn = TouchScreenButton.new()
	btn.action = action
	btn.passby_press = slide_to_press     # sliding a finger from < to > works
	btn.texture_normal = make_texture(btn_size, FILL, BORDER)
	btn.texture_pressed = make_texture(btn_size, FILL_PRESSED, BORDER_PRESSED)

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
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(label)

	add_child(btn)
	return btn


func make_texture(tex_size, fill_color, border_color):
	var img = Image.create(tex_size, tex_size, false, Image.FORMAT_RGBA8)
	var half = tex_size / 2.0
	var radius = tex_size * 0.28
	var border = 2.0

	for x in tex_size:
		for y in tex_size:
			var qx = abs(x + 0.5 - half) - (half - radius)
			var qy = abs(y + 0.5 - half) - (half - radius)
			var d = Vector2(max(qx, 0.0), max(qy, 0.0)).length() + min(max(qx, qy), 0.0) - radius
			if d > 0.0:
				img.set_pixel(x, y, Color(0, 0, 0, 0))      # outside the rounded corner
			elif d > -border:
				img.set_pixel(x, y, border_color)
			else:
				img.set_pixel(x, y, fill_color)

	return ImageTexture.create_from_image(img)


func place_buttons():
	var screen = get_viewport().get_visible_rect().size

	left_btn.position = Vector2(MARGIN, screen.y - MOVE_SIZE - MARGIN)
	right_btn.position = Vector2(MARGIN + MOVE_SIZE + BUTTON_GAP, screen.y - MOVE_SIZE - MARGIN)
	jump_btn.position = Vector2(screen.x - JUMP_SIZE - MARGIN, screen.y - JUMP_SIZE - MARGIN)
	pause_btn.position = Vector2(screen.x - PAUSE_SIZE - MARGIN, 34)
