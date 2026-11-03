extends Node2D

static var highest = 0

const SAVE_PATH = "user://save.cfg"


var chunk_width = 640
var next_chunk_x = 640
var chunk_count = 1
var last_scene = null
var gems_collected = 0
var current = 0 

var distance_score = 0
var bonus_points = 0


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
	load_highest()
	update_score()


func _on_music_finished():
	$Music.play()


func _process(delta):
	if next_chunk_x < $Player.global_position.x + 1600:
		spawn_chunk()

	remove_old_chunks()

	var distance = int($Player.global_position.x / 16)
	if distance > distance_score:
		distance_score = distance
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
			if gem.has_signal("collected"):
				gem.collected.connect(_on_gem_collected)

	for enemy in chunk.find_children("*", "", true, false):
		if enemy.has_signal("stomped") and enemy.has_method("stomp"):
			if not enemy.stomped.is_connected(_on_enemy_stomped):
				enemy.stomped.connect(_on_enemy_stomped)
				

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
	gems_collected += 1 
	bonus_points += 5
	$GemSound.pitch_scale = randf_range(0.95, 1.08)
	$GemSound.play()
	update_score()


func _on_lives_changed(_new_lives):
	save_highest()
	update_score()


func _on_game_over():
	save_highest()
	$Music.stop()
	$GameOverSound.play()
	
	var label = $UI/GameOverLabel
	label.visible = true
	label.modulate = Color(1, 1, 1, 0)

	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.6)
	await tween.finished

	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func update_score():
	var total_score = distance_score + bonus_points

	if total_score > highest:
		highest = total_score
		save_highest()
	$UI/ScoreLabel.text = "Lives: " + str($Player.lives) + "   Highest: " + str(highest) + "   Gems: " + str(gems_collected)
	$UI/DistanceLabel.text = "Score: " + str(total_score)


	
func load_highest():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		var saved = config.get_value("score", "highest", 0)
		if saved > highest:
			highest = saved

func save_highest():
	var config = ConfigFile.new()
	config.set_value("score", "highest", highest)
	var err = config.save(SAVE_PATH)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_highest()

func _on_enemy_stomped():
	bonus_points += 10
	update_score()
