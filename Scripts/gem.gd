extends Area2D

signal collected

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.name == "Player":
		collected.emit()
		spawn_sparkles()
		queue_free()


func spawn_sparkles():
	var sparkles = CPUParticles2D.new()
	sparkles.position = position
	sparkles.one_shot = true
	sparkles.emitting = true
	sparkles.amount = 10
	sparkles.lifetime = 0.5
	sparkles.explosiveness = 1.0
	sparkles.direction = Vector2(0, -1)
	sparkles.spread = 180
	sparkles.initial_velocity_min = 40
	sparkles.initial_velocity_max = 90
	sparkles.gravity = Vector2(0, 150)
	sparkles.scale_amount_min = 1.5
	sparkles.scale_amount_max = 3.0
	sparkles.color = Color("#dbd991")
	sparkles.finished.connect(sparkles.queue_free)
	get_parent().add_child.call_deferred(sparkles)
