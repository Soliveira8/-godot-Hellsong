extends Node2D

# =========================
# CONFIG
# =========================

const WATER_SIZE = 2

const VIEW_WIDTH = 640 * 2
const VIEW_HEIGHT = 360 * 2

const MAX_ACTIVE_UPDATES = 3000 * 2

const WATER_COLOR = Color(0.0, 0.232, 0.58, 0.686)

const RANDOM_LAKES = 10
const RANDOM_RIVERS = 10

const RENDER_INTERVAL = 0.05

# =========================
# DATA
# =========================

var water := {}

var render_timer := 0.0

@onready var tilemap = get_node("/root/world/NATUREZA/tileworld")
@onready var solido = tilemap.get_node("solido")

var img : Image
var tex : ImageTexture
var sprite : Sprite2D

# =========================
# READY
# =========================

func _ready():

	randomize()

	img = Image.create(
		VIEW_WIDTH,
		VIEW_HEIGHT,
		false,
		Image.FORMAT_RGBA8
	)

	img.fill(Color(0,0,0,0))

	tex = ImageTexture.create_from_image(img)

	sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	sprite.scale = Vector2(WATER_SIZE,WATER_SIZE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	add_child(sprite)

	generate_lakes()
	generate_rivers()

# =========================
# LOOP
# =========================

func _physics_process(delta):

	var cam = get_viewport().get_camera_2d()

	if cam == null:
		return

	sprite.global_position = floor(
		cam.global_position
		- Vector2(
			VIEW_WIDTH * WATER_SIZE,
			VIEW_HEIGHT * WATER_SIZE
		) / 2
	)

	mouse_spawn()

	simulate_water(cam.global_position)

	render_timer += delta

	if render_timer >= RENDER_INTERVAL:

		render_timer = 0.0
		render_water()

# =========================
# SPAWN
# =========================

func mouse_spawn():

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):

		if water.size() > 12000:
			return

		for i in 6:

			var pos = get_global_mouse_position()

			pos += Vector2(
				randi_range(-4,4),
				randi_range(-4,4)
			)

			var cell = Vector2i(
				int(pos.x / WATER_SIZE),
				int(pos.y / WATER_SIZE)
			)

			if not is_solid(cell):

				water[cell] = true

# =========================
# GENERATION
# =========================

func generate_lakes():

	for i in RANDOM_LAKES:

		var start = Vector2i(
			randi_range(-1000,1000),
			randi_range(-500,500)
		)

		var largura = randi_range(20,60)
		var altura = randi_range(8,25)

		spawn_lake(start,largura,altura)

func spawn_lake(start,largura,altura):

	for x in largura:

		var curva = int(sin(x * 0.25) * 4)

		for y in altura:

			var cell = start + Vector2i(x,y + curva)

			if not is_solid(cell):

				water[cell] = true

func generate_rivers():

	for i in RANDOM_RIVERS:

		var start = Vector2i(
			randi_range(-1000,1000),
			randi_range(-500,500)
		)

		var length = randi_range(50,200)

		spawn_river(start,length)

func spawn_river(start,length):

	var pos = start

	for i in length:

		var thickness = randi_range(3,8)

		for y in thickness:

			var cell = pos + Vector2i(0,y)

			if not is_solid(cell):

				water[cell] = true

		pos.x += randi_range(-1,1)
		pos.y += randi_range(-1,1)

# =========================
# SIMULATION
# =========================

func simulate_water(camera_pos):

	var new_water := {}

	var positions = water.keys()

	if randi() % 2 == 0:
		positions.reverse()

	var updates := 0

	var cam_cell = Vector2i(
		int(camera_pos.x / WATER_SIZE),
		int(camera_pos.y / WATER_SIZE)
	)

	# CORREÇÃO REAL 😈
	var half_w = VIEW_WIDTH / (WATER_SIZE * 2)
	var half_h = VIEW_HEIGHT / (WATER_SIZE * 2)

	var cam_left = cam_cell.x - half_w
	var cam_right = cam_cell.x + half_w

	var cam_top = cam_cell.y - half_h
	var cam_bottom = cam_cell.y + half_h

	for pos in positions:

		# FORA DA CÂMERA = CONGELADO
		if (
			pos.x < cam_left
			or pos.x > cam_right
			or pos.y < cam_top
			or pos.y > cam_bottom
		):

			new_water[pos] = true
			continue

		if updates >= MAX_ACTIVE_UPDATES:

			new_water[pos] = true
			continue

		if is_surrounded(pos):

			new_water[pos] = true
			continue

		updates += 1

		var below = pos + Vector2i(0,1)

		var down_left = pos + Vector2i(-1,1)
		var down_right = pos + Vector2i(1,1)

		var left = pos + Vector2i(-1,0)
		var right = pos + Vector2i(1,0)

		# cair
		if can_move(below,new_water):

			new_water[below] = true

		# diagonais
		elif can_move(down_left,new_water):

			new_water[down_left] = true

		elif can_move(down_right,new_water):

			new_water[down_right] = true

		# lados
		else:

			if randi() % 2 == 0:

				if can_move(left,new_water):

					new_water[left] = true

				else:

					new_water[pos] = true

			else:

				if can_move(right,new_water):

					new_water[right] = true

				else:

					new_water[pos] = true

	water = new_water

# =========================
# WATER SLEEP
# =========================

func is_surrounded(pos):

	if not water.has(pos + Vector2i(0,1)):
		return false

	if not water.has(pos + Vector2i(1,0)):
		return false

	if not water.has(pos + Vector2i(-1,0)):
		return false

	return true

# =========================
# RENDER
# =========================

func render_water():

	img.fill(Color(0,0,0,0))

	var start = Vector2i(
		int(sprite.global_position.x / WATER_SIZE),
		int(sprite.global_position.y / WATER_SIZE)
	)

	var positions = water.keys()

	for pos in positions:

		var screen_x = pos.x - start.x
		var screen_y = pos.y - start.y

		if (
			screen_x >= 0
			and screen_x < VIEW_WIDTH
			and screen_y >= 0
			and screen_y < VIEW_HEIGHT
		):

			img.set_pixel(
				screen_x,
				screen_y,
				WATER_COLOR
			)

	tex.update(img)

# =========================
# MOVEMENT
# =========================

func can_move(pos,new_water):

	if new_water.has(pos):
		return false

	if water.has(pos):
		return false

	if is_solid(pos):
		return false

	return true

# =========================
# TILE COLLISION
# =========================

func is_solid(pos):

	var world_pos = Vector2(
		pos.x * WATER_SIZE,
		pos.y * WATER_SIZE
	)

	var local = solido.to_local(world_pos)

	var cell = solido.local_to_map(local)

	return solido.get_cell_source_id(cell) != -1
