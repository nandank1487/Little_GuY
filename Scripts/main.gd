extends Node2D

static var highest = 0

var chunk_width = 640
var next_chunk_x = 640
var chunk_count = 1
var last_scene = null
var gems_collected = 0



var level_chunks = [
	preload("res://Scenes/chunk_2.tscn"),
	preload("res://Scenes/chunk_3.tscn"),
	preload("res://Scenes/chunk_4.tscn"),
	preload("res://Scenes/chunk_6.tscn"),
	preload("res://Scenes/chunk_7.tscn"),
	preload("res://Scenes/chunk_8.tscn"),
	preload("res://Scenes/chunk_9.tscn"),
	preload("res://Scenes/chunk_10.tscn"),
]



var rest_stop = preload("res://Scenes/chunk_5.tscn")
var checkpoint_scene = preload("res://Scenes/checkpoint.tscn")



func _ready():
	# Loop the music when it finishes
	$Music.finished.connect(_on_music_finished)

	$UI/GameOverLabel.visible = false
	$Player.lives_changed.connect(_on_lives_changed)
	$Player.game_over.connect(_on_game_over)

	setup_chunk($Chunks/Chunk1)
	update_score()


func _on_music_finished():
	$Music.play()


func _process(delta):
	if next_chunk_x < $Player.global_position.x + 1600:
		spawn_chunk()

	remove_old_chunks()

	var distance = int($Player.global_position.x / 16)
	if distance > highest:
		highest = distance
		update_score()



func spawn_chunk():
	var scene = null

	if chunk_count % 4 == 0:
		scene = rest_stop
	else:
		scene = level_chunks.pick_random()
		while scene == last_scene:
			scene = level_chunks.pick_random()

	var chunk = scene.instantiate()
	chunk.position = Vector2(next_chunk_x, 0)
	$Chunks.add_child(chunk)
	setup_chunk(chunk)

	last_scene = scene
	next_chunk_x = next_chunk_x + chunk_width
	chunk_count = chunk_count + 1



func setup_chunk(chunk):
	if chunk.has_node("Gems"):
		var gems_folder = chunk.get_node("Gems")
		for gem in gems_folder.get_children():
			gem.collected.connect(_on_gem_collected)

	# To put a checkpoint flag at the end of each chunk
	var flag = checkpoint_scene.instantiate()
	flag.position = Vector2(608, 296)
	chunk.add_child(flag)



func remove_old_chunks():
	var safe_x = $Player.global_position.x
	if $Player.respawn_position.x < safe_x:
		safe_x = $Player.respawn_position.x


	# To delete the chunks that are way behind us
	for chunk in $Chunks.get_children():
		if chunk.position.x + chunk_width < safe_x - 1300:
			chunk.queue_free()


func _on_gem_collected():
	gems_collected = gems_collected + 1
	$GemSound.play()
	update_score()


func _on_lives_changed(new_lives):
	update_score()

func _on_game_over():
	$Music.stop()
	$GameOverSound.play()
	$UI/GameOverLabel.visible = true

	# to wait 2 seconds and restart the game
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func update_score():
	$UI/ScoreLabel.text = "Lives: " + str($Player.lives) + "   Highest: " + str(highest) + "   Gems: " + str(gems_collected)
