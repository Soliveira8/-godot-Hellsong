extends Node2D

# =========================================
# TILEMAP
# =========================================

@onready var tilemap = get_node("/root/world/NATUREZA/tileworld")
@onready var solido = tilemap.get_node("solido")

# =========================================
# CONFIG
# =========================================

const WATER_SIZE = 2
const SNOW_COUNT = 3000
const SNOW_FALL_SPEED = 1

# =========================================
# GRID
# =========================================

var snow_grid := {}

# =========================================
# READY
# =========================================

func _ready():
	randomize()
	generate_snow()

# =========================================
# GENERATE
# =========================================

func generate_snow():

	var rect = solido.get_used_rect()

	for i in SNOW_COUNT:

		var cell = Vector2i(
			randi_range(rect.position.x, rect.position.x + rect.size.x),
			randi_range(rect.position.y, rect.position.y + rect.size.y)
		)

		snow_grid[cell] = {
			"moving": true
		}

# =========================================
# DRAW
# =========================================

func _draw():

	for cell in snow_grid.keys():

		draw_rect(
			Rect2(
				cell.x * WATER_SIZE,
				cell.y * WATER_SIZE,
				WATER_SIZE,
				WATER_SIZE
			),
			Color.WHITE
		)

# =========================================
# UPDATE
# =========================================

func _process(delta):

	var new_grid := {}

	for cell in snow_grid.keys():

		var data = snow_grid[cell]

		if !data.moving:
			new_grid[cell] = data
			continue

		var below = cell + Vector2i(0, SNOW_FALL_SPEED)

		var world_pos = Vector2(
			below.x * WATER_SIZE,
			below.y * WATER_SIZE
		)

		var map_cell = solido.local_to_map(
			solido.to_local(world_pos)
		)

		var tile_data = solido.get_cell_tile_data(map_cell)

		var blocked_by_snow = (
			snow_grid.has(below) or new_grid.has(below)
		)

		if tile_data == null and !blocked_by_snow:
			new_grid[below] = data
		else:
			data.moving = false
			new_grid[cell] = data

	snow_grid = new_grid
	queue_redraw()
