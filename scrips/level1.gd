extends Node

# --- Preload obstacles ---
var stump_scene = preload("res://scenes/level1/stump.tscn")
var barrel_scene = preload("res://scenes/level1/barrel.tscn")
var obstacle_types := [stump_scene, barrel_scene]
var obstacles : Array = []

# --- Game variables ---
const R_START_POS := Vector2i(150, 400)
const CAM_START_POS := Vector2i(576, 324)
var score: float = 0
var speed: float = 0.0
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
var screen_size: Vector2i
var ground_height : int
var difficulty: float = 0
const MAX_DIFFICULTY : int = 2
const SPEED_MODIFIER : int = 5000
const LEVEL_END_SCORE : int = 20000 
var game_running : bool = false
var last_obs

# --- Game start flag ---
var started: bool = false
var level_completed: bool = false

func _ready() -> void:
	screen_size = get_window().size
	ground_height = $floor.get_node("Sprite2D").texture.get_height()
	if $GameOver.has_node("Button"):
		$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game() -> void:
	score = 0
	difficulty = 0
	game_running = false
	started = false
	level_completed = false
	get_tree().paused = false

	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()

	$player.position = R_START_POS
	$player.velocity = Vector2i(0, 0)
	$player.z_index = 10
	$player.started = false
	$player.get_node("AnimatedSprite2D").play("idle")

	$Camera2D.position = CAM_START_POS
	$floor.position = Vector2i(0, 0)

	update_score_labels()
	$HUD1/S.visible = true
	$HUD1/S.text = "Press Enter to Start"
	$GameOver.hide()

func _process(_delta: float) -> void:
	if not started:
		if Input.is_action_just_pressed("ui_accept"):
			started = true
			game_running = true
			$HUD1/S.visible = false
			$player.started = true
		return

	# After level completion: wait for Enter to go to Level 2
	if level_completed:
		$player.get_node("AnimatedSprite2D").play("idle")  # ensure idle state
		if Input.is_action_just_pressed("ui_accept"):
			load_level2()
		return

	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()

		generate_obs()
		$player.position.x += speed
		$Camera2D.position.x += speed
		score += speed
		update_score_labels()

		if score >= 19000:
			pass  # stop generating new obstacles beyond this point

		if score >= LEVEL_END_SCORE:
			level_finished()
			return

		if $Camera2D.position.x - $floor.position.x > screen_size.x * 1.5:
			$floor.position.x += screen_size.x

		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD1/S.hide()

# --- Obstacle functions ---
func generate_obs() -> void:
	if score >= 18500:
		return

	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
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

func add_obs(obs, x, y) -> void:
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs) -> void:
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body) -> void:
	if body.name == "player":
		game_over()

# --- Score / Difficulty functions ---
func update_score_labels() -> void:
	var remaining = LEVEL_END_SCORE - int(score)
	if remaining < 0:
		remaining = 0
	$HUD1/ScoreLabel.text = "Score: %d" % int(score / 10)
	$HUD1/H.text = "Remaining: %d" % int(remaining / 10.0)


func adjust_difficulty() -> void:
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over() -> void:
	get_tree().paused = true
	game_running = false
	$GameOver.show()

func level_finished() -> void:
	game_running = false
	level_completed = true
	$player.get_node("AnimatedSprite2D").play("idle")  # set idle
	$HUD1/S.visible = true
	$HUD1/S.text = "Level Complete!"
	print("Level 1 finished! Ready to go to Level 2?")

func load_level2() -> void:
	var level2_scene = preload("res://scenes/level2/level2.tscn")
	get_tree().change_scene_to_packed(level2_scene)
