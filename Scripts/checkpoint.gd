extends Area2D

var active = false

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if active == true:
		return



	if body.name == "Player":
		body.set_checkpoint(global_position)
		active = true
		$ChimeSound.play()
		$Flag.color = Color("#dbd991")
