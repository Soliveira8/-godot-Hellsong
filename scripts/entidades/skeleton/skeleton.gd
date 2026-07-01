extends Node2D

@export var anim: AnimatedSprite2D
@export var charac: CharacterBody2D

enum states {idle, walk, atk, fall, libre}

var state = states.idle
var dire = [-1, 1]
var dir = dire.pick_random()

var cowstate = 4.0
var velval = 20.0
var gravity = 980.0

func _ready() -> void:
	z_index = 10

func _process(delta: float) -> void:
	cowstate -= delta

	# Gravidade
	if !charac.is_on_floor():
		charac.velocity.y += gravity * delta
		state = states.fall
	else:
		if state == states.fall:
			state = states.idle

	# Escolhe ações aleatórias
	if cowstate <= 0 and charac.is_on_floor():
		state = [states.idle, states.walk, states.atk].pick_random()
		dir = dire.pick_random()

		anim.scale.x = abs(anim.scale.x) * dir

		cowstate = randf_range(2.0, 4.0)

	_statemachine()

	charac.move_and_slide()

func _statemachine():
	match state:
		states.idle:
			anim.play("idle")
			charac.velocity.x = 0

		states.walk:
			anim.play("walk")
			charac.velocity.x = dir * velval

		states.atk:
			anim.play("atk")
			charac.velocity.x = 0

			if anim.frame >= anim.sprite_frames.get_frame_count("atk") - 1:
				state = states.idle

		states.fall:
			anim.play("fall") # troque se não tiver animação fall

		states.libre:
			pass
