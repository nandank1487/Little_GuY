extends Camera2D


var shake_strength = 0.0

func shake(amount = 6.0):
	shake_strength = amount

func _process(delta):
	if shake_strength > 0.1:
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
		shake_strength = lerpf(shake_strength, 0, 10 * delta)
	else:
		shake_strength = 0
		offset = Vector2.ZERO
