extends Control

var time = 0.0

func _ready():
	print("aspect: ", get_window().content_scale_aspect, "  window: ", get_window().size, "  visible: ", get_viewport().get_visible_rect().size)
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/StartButton.grab_focus()
	var config = ConfigFile.new()
	var result = config.load("user://save.cfg")
	var best = 0
	if result == OK:
		best = config.get_value("score", "highest", 0)
	if has_node("VBoxContainer/HighestLabel"):
		$VBoxContainer/HighestLabel.text = "Highest: " + str(best)


func _process(delta):
	# the little character bounce up and down on the menu screen
	time = time + delta
	var bounce = abs(sin(time * 3.0)) * 12.0
	$LittleGuy.position.y = 296.0 - bounce


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


