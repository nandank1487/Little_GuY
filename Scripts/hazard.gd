extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	# Kill the player if it touch this hazard
	if body.name == "Player":
		body.die()
