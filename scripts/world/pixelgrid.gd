extends Node2D

var GRID_WIDTH : int
var GRID_HEIGHT : int

var grid = []

@onready var solido := get_tree().get_first_node_in_group("solido")

func _ready():
	if solido == null:
		print("TileMap não encontrado!")
		return
	
	var used_rect = solido.get_used_rect()
	GRID_WIDTH = used_rect.size.x
	GRID_HEIGHT = used_rect.size.y
	
	print("Grid size:", GRID_WIDTH, GRID_HEIGHT)
	
	grid.resize(GRID_HEIGHT)
	for y in range(GRID_HEIGHT):
		grid[y] = []
		grid[y].resize(GRID_WIDTH)
		for x in range(GRID_WIDTH):
			grid[y][x] = 0

	set_process(true)


func _process(delta):
	update_water()
	queue_redraw()


func spawn_water(world_pos:Vector2):
	var tile_pos = solido.local_to_map(world_pos)
	var x = tile_pos.x
	var y = tile_pos.y
	
	if inside_grid(x, y):
		grid[y][x] = 1


func inside_grid(x,y):
	return x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT


func is_solid(x,y):
	if not inside_grid(x,y):
		return true
	
	var cell = solido.get_cell_source_id(0, Vector2i(x,y))
	return cell != -1


func update_water():
	for y in range(GRID_HEIGHT - 2, -1, -1):
		for x in range(GRID_WIDTH):
			if grid[y][x] == 1:
				
				# cair
				if inside_grid(x,y+1) and grid[y+1][x] == 0 and not is_solid(x,y+1):
					grid[y][x] = 0
					grid[y+1][x] = 1
				
				else:
					# lateral
					var dir = [-1,1].pick_random()
					var nx = x + dir
					
					if inside_grid(nx,y+1) and grid[y+1][nx] == 0 and not is_solid(nx,y+1):
						grid[y][x] = 0
						grid[y+1][nx] = 1


func _draw():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] == 1:
				var world_pos = solido.map_to_local(Vector2i(x,y))
				draw_rect(Rect2(world_pos, Vector2(16,16)), Color.BLUE)
