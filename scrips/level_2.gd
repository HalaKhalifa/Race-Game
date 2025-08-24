extends Node

# --- Preload obstacles for Level 2 ---
var stump_scene = preload("res://scenes/level2/stump.tscn")
var rock_scene = preload("res://scenes/level2/rock.tscn")
var barrel_scene = preload("res://scenes/level2/barrel.tscn")
var bird_scene = preload("res://scenes/level2/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array = []
var bird_heights := [180, 350]  # slightly lower to make it harder

# --- Game variables ---
const R_START_POS := Vector2i(150, 400)
const CAM_START_POS := Vector2i(576, 324)
var score: float = 0
var high_score: float = 0
var speed: float = 0.0
const START_SPEED: float = 12.0  # increased start speed
const MAX_SPEED: int = 30        # higher max speed for level 2
var screen_size: Vector2i
var ground_height : int
var difficulty: float = 0
const MAX_DIFFICULTY : int = 3   # level 2 is harder
const SCORE_MODIFIER : int = 8   # score grows faster
const SPEED_MODIFIER : int = 4500
var game_running : bool = false
var last_obs
# --- Game start flag ---
var started: bool = false

func _ready() -> void:
	screen_size = get_window().size
	ground_height = $floor.get_node("Sprite2D").texture.get_height()
	if $GameOver.has_node("Button"):
		$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game() -> void:
	# reset state
	score = 0
	difficulty = 0
	game_running = false
	started = false
	get_tree().paused = false
	$HUD2/Level.text = "Level 2"

	# delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()

	# reset player2
	$player2.position = R_START_POS
	$player2.velocity = Vector2i(0, 0)
	$player2.z_index = 10
	$player2.started = false

	# reset camera and floor
	$Camera2D.position = CAM_START_POS
	$floor.position = Vector2i(0, 0)

	# HUD2
	$HUD2/ScoreLabel.text = "Score : 0"
	$HUD2/H.text = "High Score : %d" % int(high_score / SCORE_MODIFIER)
	$HUD2/S.visible = true
	$GameOver.hide()

func _process(_delta: float) -> void:
	if not started:
		if Input.is_action_just_pressed("ui_accept"):
			started = true
			game_running = true
			$HUD2/S.visible = false
			$player2.started = true
		return

	if game_running:
		# Speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()

		# Generate obstacles
		generate_obs()

		# Move player2 and camera
		$player2.position.x += speed
		$Camera2D.position.x += speed

		# Update score
		score += speed
		show_score()

		# Floor shift
		if $Camera2D.position.x - $floor.position.x > screen_size.x * 1.5:
			$floor.position.x += screen_size.x

		# Remove offscreen obstacles
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD2.get_node("StartLabel").hide()

# --- Obstacle functions ---
func generate_obs() -> void:
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(250, 450):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = int(difficulty) + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

		# Chance to spawn bird at max difficulty
		if difficulty >= MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = bird_scene.instantiate()
				var min_gap : int = 150
				var obs_x : int
				if last_obs:
					obs_x = last_obs.position.x + min_gap
				else:
					obs_x = roundi(screen_size.x) + int(score) + int(min_gap)
				var obs_y = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y) -> void:
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs) -> void:
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body) -> void:
	if body.name == "player2":
		game_over()

# --- Score / Difficulty functions ---
func show_score() -> void:
	$HUD2/ScoreLabel.text = "Score : %d" % int(score / SCORE_MODIFIER)

func check_high_score() -> void:
	if score > high_score:
		high_score = score
	$HUD2/H.text = "High Score : %d" % int(high_score / SCORE_MODIFIER)

func adjust_difficulty() -> void:
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over() -> void:
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
