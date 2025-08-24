extends Control

# Configurable from Inspector
@export var system_prompt: String = "You are a friendly NPC giving very short comments about the game."
@export var interval_sec: float = 4.0            # Interval in seconds between messages
@export var use_fixed_lines: bool = false        # If true, use fixed lines instead of LLM
@export var fixed_lines: PackedStringArray = [   # Only used if use_fixed_lines = true
	"Go!",
	"Watch out!",
	"Nice jump!",
	"Keep going!"
]

@onready var ai_text: RichTextLabel = $PanelContainer/VBoxContainer/AIText
@onready var ai_chat: Node = $AIChat
@onready var ai_model: Node = $AIModel

var _timer: Timer
var _busy := false

# Short prompts to avoid overflow
var _prompts := [
	"Go!",
	"Watch out!",
	"Nice jump!",
	"Keep going!"
]

func _ready():
	# Setup LLM
	ai_chat.model_node = ai_model
	ai_chat.system_prompt = system_prompt
	ai_chat.start_worker()

	# Connect signals
	ai_chat.response_updated.connect(_on_ai_response_updated)
	ai_chat.response_finished.connect(_on_ai_response_finished)

	# Timer for periodic messages
	_timer = Timer.new()
	_timer.wait_time = interval_sec
	_timer.one_shot = false
	_timer.autostart = true
	add_child(_timer)
	_timer.timeout.connect(_tick)

	# First message immediately
	_tick()

func _tick():
	if _busy:
		return
	_busy = true
	ai_text.text = ""

	if use_fixed_lines:
		# Display a fixed line without LLM
		ai_text.text = "..." if fixed_lines.is_empty() else fixed_lines[randi() % fixed_lines.size()]
		_busy = false
		return

	# With LLM: send a short prompt
	var p = _prompts[randi() % _prompts.size()]
	ai_chat.say(p)

func _on_ai_response_updated(new_token: String) -> void:
	if !use_fixed_lines:
		ai_text.text += new_token

func _on_ai_response_finished(_response: String) -> void:
	_busy = false

# Optional APIs to trigger messages based on game events
func comment_on_score(score: int):
	if use_fixed_lines or _busy: return
	_busy = true
	ai_text.text = ""
	ai_chat.say("Very short comment for %d points." % score)

func comment_on_death():
	if use_fixed_lines or _busy: return
	_busy = true
	ai_text.text = ""
	ai_chat.say("Very short comment after player death.")
