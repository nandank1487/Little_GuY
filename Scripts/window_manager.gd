extends Node

func _ready():
	print("aspect: ", get_window().content_scale_aspect, "  size: ", get_window().size)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
