extends CharacterBody2D


var speed = 40.0
var direction = -1          # -1 = left, 1 = right
var is_dying = false

@onready var visual = $Visual
@onready var floor_check = $FloorCheck
@onready var hitbox = $Hitbox



func _ready():
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	floor_check.position.x = 8 * direction


func _on_hitbox_area_entered(area):
	if is_dying:
		return
	if area.is_in_group("hazard"):
		turn_around()



func _physics_process(delta):
	if is_dying:
		return

	if not is_on_floor():
		velocity = velocity + get_gravity() * delta

	velocity.x = direction *speed
	move_and_slide()

	# To turn around a wall, or at the edge of a platform

	if is_on_wall() or (is_on_floor() and not floor_check.is_colliding()):
		turn_around()

	if global_position.y > 600:
		queue_free()




func turn_around():
	direction = -direction
	floor_check.position.x = 8 * direction
	floor_check.force_raycast_update() # to make sure it checks the new side right away
	visual.flip_h = direction > 0




func _on_hitbox_body_entered(body):
	if is_dying or body.name != "Player":
		return

	# Stomp: the player is falling and hits the enemy from above

	var stomped = body.velocity.y > 0 and body.global_position.y < global_position.y - 4
	if stomped:
		stomp(body)
	else:
		body.die()


func stomp(player):
	is_dying = true
	hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)

	# Bounce the Player Upwards
	player.velocity.y = player.jump_velocity * 0.7
	player.squash(0.75, 1.25)

	# Squish flat and then Disappear
	var tween = create_tween()
	tween.tween_property(visual, "scale:y", 0.0, 0.12)
	tween.tween_callback(queue_free)
