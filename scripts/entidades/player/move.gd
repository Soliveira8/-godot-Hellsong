extends CharacterBody2D

@export var speedclimb = 0.2
@export var anim: AnimatedSprite2D

@export var debugprint = true

@onready var tileworld := get_tree().get_first_node_in_group("tileworld")

# colisões 😈
@onready var climbcol = $climbcol
@onready var normalcol = $bodycol

enum states {
	idle,
	walk,
	run,
	jump,
	agachando,
	atack,
	littlejump,
	air,
	derrapando,
	climb,
	climbtojump,
	climbtile
}

const aceleration = 100
const SPEED = 80
const JUMP_VELOCITY = -200

var friction = SPEED * 5
var walldash = 10.0

var state = states.idle

var direction: int
var atrito = 10
var gravity = 500
var directionpure = 0

var chao = false
var grabwall = false

# ========================================
# READY
# ========================================

func _ready() -> void:

	set_normal_collision()

	if debugprint:
		print(tileworld)

# ========================================
# PHYSICS
# ========================================

func _physics_process(delta: float) -> void:

	if debugprint:
		print(states.keys()[state])

	statemachine(delta)

	processingvariables(delta)

	move_and_slide()

# ========================================
# INPUT
# ========================================

func _input(event: InputEvent) -> void:

	if event is InputEventKey:

		if event.pressed:

			if event.keycode == KEY_SPACE:
				rotation = 0

			

# ========================================
# COLLISIONS
# ========================================

func set_climb_collision():

	normalcol.disabled = true
	climbcol.disabled = false

func set_normal_collision():

	normalcol.disabled = false
	climbcol.disabled = true

# ========================================
# PROCESS VARIABLES
# ========================================

func processingvariables(delta):

	walldash = lerp(walldash,0.0,2.0)

	direction = Input.get_axis("ui_left","ui_right")
	

	if not is_on_floor() and state != states.climb:
		velocity.y += delta * gravity
	else:
		if velocity.y >= 0:
			velocity.y = 0

	if direction != 0 and state != states.climb and state != states.air:
		anim.scale.x = sign(direction)

# ========================================
# STATE HELPERS
# ========================================

func atk():
	if Input.is_action_just_pressed("atack"):
		state = states.atack
		walldash = 100.0
func handle_jump(delta):

	if is_on_floor():

		if Input.is_action_just_pressed("ui_accept"):
			state = states.jump
func run(delta,direction):

	if direction != 0 and state != states.jump and state != states.littlejump and is_on_floor():

		if is_on_wall():

			var wall_dir = get_wall_normal().x

			if direction == -wall_dir:

				velocity.x = 0
				state = states.idle
				return

		state = states.run
func fricton(delta,direction):

	if direction == 0 and not Input.is_action_pressed("ui_down") and velocity.y == 0 and state != states.jump:
		state = states.idle
func agachando(delta,friction,direction):

	if Input.is_action_pressed("ui_down"):
		state = states.agachando

	if is_on_floor() and direction != 0 and sign(velocity.x) != direction and abs(velocity.x) > 10:
		state = states.agachando
func scratchtoidle():

	if abs(velocity.x) < 5 and not Input.is_action_pressed("ui_down"):
		state = states.idle
func climb():

	var climb_pressed = Input.is_key_pressed(KEY_K) \
		or Input.is_joy_button_pressed(0, JOY_BUTTON_RIGHT_SHOULDER)

	if climb_pressed and is_on_wall():
		grabwall = true
		state = states.climb
func climbtojump():

	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0,JOY_BUTTON_A):
		state = states.climbtojump
func idle():

	if direction == 0 and is_on_floor():
		state = states.idle
func air():

	if state == states.climb and not is_on_wall():
		state = states.air
	
	if state != states.climb and not is_on_floor():
		state = states.air
	

# ========================================
# STATE MACHINE
# ========================================

func statemachine(delta):

	match state:
		states.idle:

			set_normal_collision()

			velocity.x = lerp(velocity.x,0.0,0.1)

			anim.play("Ivan_idle")
			anim.frame = 0

			run(delta,direction)
			agachando(delta,friction,direction)
			
			air()
			atk()
		states.walk:
			pass
		states.run:

			set_normal_collision()

			velocity.x = move_toward(
				velocity.x,
				SPEED * direction,
				aceleration * delta
			)

			anim.speed_scale = lerp(
				anim.speed_scale,
				8.0,
				aceleration / 100 * delta
			)

			anim.play("Ivan_running")

			fricton(delta,direction)
			handle_jump(delta)
			agachando(delta,friction,direction)
			idle()
			climb()
			air()
			atk()
		states.jump:

			set_normal_collision()

			velocity.y = JUMP_VELOCITY

			if tileworld:
				tileworld.grass_to_dirt_at(global_position)

			air()
			climb()
		states.littlejump:

			set_normal_collision()

			velocity.y = JUMP_VELOCITY / 4

			air()
		states.agachando:

			set_normal_collision()

			anim.play("Ivan_agachado")

			velocity.x = lerp(
				velocity.x,
				0.0,
				atrito * delta
			)

			scratchtoidle()
			handle_jump(delta)
		states.atack:

			set_normal_collision()
			anim.play("Ivan_atk")
			anim.speed_scale = 4
			
		
				

				
			velocity.x -= walldash * direction

			velocity.y -= 10.0	

				

			if anim.frame >= anim.sprite_frames.get_frame_count(anim.animation) - 1:
				state = states.idle
		states.air:

			set_normal_collision()

			anim.play("Ivan_jump")
			anim.frame = 4
			anim.speed_scale = 5

			if velocity.y > 0:
				anim.frame = 36

			fricton(delta,direction)
			climb()
			idle()
			run(delta,direction)
		states.climb:
			
			set_climb_collision()

			velocity = Vector2.ZERO

			anim.play("Ivan_agarrado")
			anim.speed_scale = 0
			var axis_y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
			if Input.is_key_pressed(KEY_W) or axis_y < -0.5:

				position -= Vector2(0,speedclimb)

				anim.speed_scale = 5

			if Input.is_key_pressed(KEY_S) or axis_y > 0.5:

				position += Vector2(0,speedclimb)

				anim.speed_scale = 5

			air()
			climbtojump()
		states.climbtojump:

			set_climb_collision()

			if direction != get_wall_normal().x:

				
				
				state = states.climb

			if direction == get_wall_normal().x:

				walldash = 100.0

				velocity.x += walldash * direction

				velocity.y += JUMP_VELOCITY

				state = states.air
