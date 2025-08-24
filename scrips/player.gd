extends CharacterBody2D

const GRAVITY: int = 4200
const JUMP_SPEED: int = -1800

var started: bool = false  # set by Main when the game begins
var finished: bool = false # set by Main when level ends

func _physics_process(delta: float) -> void:
	# Before game starts or after level finished: stay idle
	if not started or finished:
		velocity = Vector2.ZERO
		$run.disabled = false
		$AnimatedSprite2D.play("idle")
		move_and_slide()
		return

	# Normal gameplay
	velocity.y += GRAVITY * delta

	if is_on_floor():
		$run.disabled = false
		if Input.is_action_pressed("ui_accept"):
			velocity.y = JUMP_SPEED
			$JumpSound.play()
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("down")
			$run.disabled = true
		else:
			$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")

	move_and_slide()
