extends CharacterBody2D


signal lives_changed(lives)
signal game_over

var speed = 175.0
var jump_velocity = -300.0

var coyote_time = 0.1
var jump_buffer_time = 0.1
var jump_cut = 0.4

var coyote_timer = 0.0
var jump_buffer_timer = 0.0

var feet_offset = 8.0   # about half the little guy's height in pixels, keeps feet planted
var was_on_floor = false
var last_fall_speed = 0.0

var lives = 5
var respawn_position = Vector2.ZERO
var is_dead = false

var invincible_timer = 0


@onready var visual = $Visual
@onready var land_dust = $LandDust

func _ready():
	respawn_position = global_position


func _physics_process(delta):
	if is_dead == true:
		return

	if global_position.y > 450:
		die()

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = coyote_timer - delta
		velocity = velocity + get_gravity() * delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = jump_buffer_timer - delta

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0
		coyote_timer = 0
		$JumpSound.play()
		squash(0.75, 1.25)  

	# Let go of jump early = shorter jump
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = velocity.y * jump_cut

	# Movement
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	# Remember how fast we were falling before landing zeroes it
	last_fall_speed = velocity.y

	move_and_slide()

	if is_on_floor() and not was_on_floor and last_fall_speed > 80:
		squash(1.3, 0.7)     # squish flat when landing
		land_dust.restart()
	was_on_floor = is_on_floor()

	if invincible_timer > 0:
		invincible_timer -= delta
		visual.visible = fmod(invincible_timer, 0.16) < 0.08
	else:
		visual.visible = true



var squash_tween: Tween

func squash(scale_x, scale_y):
	if squash_tween and squash_tween.is_running():
		squash_tween.kill()
	visual.scale = Vector2(scale_x, scale_y)
	visual.position.y = (1.0 - scale_y) * feet_offset
	squash_tween = create_tween().set_parallel(true)
	squash_tween.tween_property(visual, "scale", Vector2.ONE, 0.15)
	squash_tween.tween_property(visual, "position:y", 0.0, 0.15)

func die():
	if lives <= 0 or invincible_timer > 0:
		return
	invincible_timer = 2.0

	lives = lives - 1
	$HurtSound.play()
	lives_changed.emit(lives)

	var cam = get_viewport().get_camera_2d()
	if cam != null and cam.has_method("shake"):
		cam.shake(6.0) 

	if lives == 0:
		is_dead = true
		hide()
		game_over.emit()
	else:
		# Teleport back to the last checkpoint
		global_position = respawn_position
		velocity = Vector2.ZERO
		coyote_timer = 0
		jump_buffer_timer = 0


func set_checkpoint(pos):
	var new_y = pos.y - 12
	if global_position.y < new_y:
		new_y = global_position.y
	respawn_position = Vector2(pos.x, new_y -12)
