extends Control


func _ready():
	# Always keep running while game is paused, so we can still Resume
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$VBoxContainer/ResumeButton.pressed.connect(resume)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _input(event):
	if event.is_action_pressed("pause"):
		# No pausing when dead
		var player = get_tree().current_scene.get_node("Player")
		if player.is_dead:
			return
		if get_tree().paused:
			resume()
		else:
			pause()
		get_viewport().set_input_as_handled()


func pause():
	get_tree().paused = true
	visible = true
	$VBoxContainer/ResumeButton.grab_focus()
	var main = get_tree().current_scene
	$VBoxContainer/HighestLabel.text = "Highest: " + str(main.highest)


func resume():
	get_tree().paused = false
	visible = false


func _on_quit_pressed():
	get_tree().current_scene.save_highest()
	get_tree().paused = false # must unpause before changing scene
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")



