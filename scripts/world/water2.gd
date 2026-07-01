extends Node2D

# =========================================
# WATER 2.0 ☠️🌊
# ARRAY VERSION
# =========================================

const WORLD_WIDTH = 2048
const WORLD_HEIGHT = 2048

const WATER_SIZE = 1

const EMPTY = 0
const WATER = 1

const VIEW_WIDTH = 640
const VIEW_HEIGHT = 360

const MAX_UPDATES = 4000

const WATER_COLOR = Color(0.1,0.45,1.0,0.5)

# =========================================
# GRID
# =========================================

var grid := PackedByteArray()

# double buffer 😈
var next_grid := PackedByteArray()

@onready var tilemap = get_node("/root/world/NATUREZA/tileworld")
@onready var solido = tilemap.get_node("solido")

var img : Image
var tex : ImageTexture
var sprite : Sprite2D

# =========================================
# READY
# =========================================

func _ready():

	# cria grid
	grid.resize(WORLD_WIDTH * WORLD_HEIGHT)
	next_grid.resize(WORLD_WIDTH * WORLD_HEIGHT)

	# imagem render
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
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	add_child(sprite)

# =========================================
# LOOP
# =========================================

func _physics_process(delta):

	var cam = get_viewport().get_camera_2d()

	sprite.global_position = floor(
		cam.global_position
		- Vector2(VIEW_WIDTH,VIEW_HEIGHT)/2
	)

	mouse_spawn()

	simulate(cam.global_position)

	render_water()

# =========================================
# SPAWN
# =========================================

func mouse_spawn():

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):

		for i in 8:

			var pos = get_global_mouse_position()

			pos += Vector2(
				randi_range(-4,4),
				randi_range(-4,4)
			)

			var x = int(pos.x)
			var y = int(pos.y)

			if inside(x,y):

				if not is_solid(x,y):

					set_cell(x,y,WATER)

# =========================================
# SIMULATION
# =========================================

func simulate(camera_pos):

	# limpa próximo frame
	next_grid.fill(0)

	var updates := 0

	var cam_x = int(camera_pos.x)
	var cam_y = int(camera_pos.y)

	# só simula perto câmera 😈
	var start_x = clamp(cam_x - 350,0,WORLD_WIDTH)
	var end_x = clamp(cam_x + 350,0,WORLD_WIDTH)

	var start_y = clamp(cam_y - 250,0,WORLD_HEIGHT)
	var end_y = clamp(cam_y + 250,0,WORLD_HEIGHT)

	for y in range(end_y - 1,start_y,-1):

		for x in range(start_x,end_x):

			if updates >= MAX_UPDATES:
				break

			if get_cell(x,y) != WATER:
				continue

			# água interna dorme 😴
			if surrounded(x,y):

				next_grid[index(x,y)] = WATER
				continue

			updates += 1

			var moved = false

			# baixo
			if can_move(x,y+1):

				next_grid[index(x,y+1)] = WATER
				moved = true

			# diagonal esquerda
			elif can_move(x-1,y+1):

				next_grid[index(x-1,y+1)] = WATER
				moved = true

			# diagonal direita
			elif can_move(x+1,y+1):

				next_grid[index(x+1,y+1)] = WATER
				moved = true

			else:

				# lateral
				if randi() % 2 == 0:

					if can_move(x-1,y):

						next_grid[index(x-1,y)] = WATER
						moved = true

				else:

					if can_move(x+1,y):

						next_grid[index(x+1,y)] = WATER
						moved = true

			# parado
			if not moved:

				next_grid[index(x,y)] = WATER

	# swap buffers 😈
	var temp = grid
	grid = next_grid
	next_grid = temp

# =========================================
# RENDER
# =========================================

func render_water():

	img.fill(Color(0,0,0,0))

	var start_x = int(sprite.global_position.x)
	var start_y = int(sprite.global_position.y)

	for y in range(VIEW_HEIGHT):

		for x in range(VIEW_WIDTH):

			var world_x = x + start_x
			var world_y = y + start_y

			if not inside(world_x,world_y):
				continue

			if get_cell(world_x,world_y) == WATER:

				img.set_pixel(
					x,
					y,
					WATER_COLOR
				)

	tex.update(img)

# =========================================
# HELPERS
# =========================================

func surrounded(x,y):

	if get_cell(x,y+1) != WATER:
		return false

	if get_cell(x-1,y) != WATER:
		return false

	if get_cell(x+1,y) != WATER:
		return false

	return true


func can_move(x,y):

	if not inside(x,y):
		return false

	if get_cell(x,y) != EMPTY:
		return false

	if is_solid(x,y):
		return false

	return true


func index(x,y):

	return x + y * WORLD_WIDTH


func get_cell(x,y):

	return grid[index(x,y)]


func set_cell(x,y,value):

	grid[index(x,y)] = value


func inside(x,y):

	return (
		x >= 0
		and x < WORLD_WIDTH
		and y >= 0
		and y < WORLD_HEIGHT
	)

# =========================================
# TILE COLLISION
# =========================================

func is_solid(x,y):

	var local = solido.to_local(Vector2(x,y))

	var cell = solido.local_to_map(local)

	return solido.get_cell_source_id(cell) != -1
