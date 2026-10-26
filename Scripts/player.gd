extends CharacterBody2D

signal lives_changed(lives)
signal game_over

var speed = 120.0
var jump_velocity = -300.0

var lives = 5
var respawn_position = Vector2.ZERO
var is_dead = false

func _ready():
	respawn_position = global_position
		




func _physics_process(delta):
	if is_dead == true:
		return

	# To dall in a hole and die if we go too low
	if global_position.y > 450:
		die()

	# Gravity when in the air
	if not is_on_floor():
		velocity = velocity + get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		$JumpSound.play()

	# Movement
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	move_and_slide()



func die():
	if lives <= 0:
		return

	lives = lives - 1
	$HurtSound.play()
	lives_changed.emit(lives)

	if lives == 0:
		is_dead = true
		hide()
		game_over.emit()
	else:
		# Teleport back to the last checkpoint
		global_position = respawn_position
		velocity = Vector2.ZERO



func set_checkpoint(pos):
	var new_y = pos.y - 12
	if global_position.y < new_y:
		new_y = global_position.y
	respawn_position = Vector2(pos.x, new_y)
