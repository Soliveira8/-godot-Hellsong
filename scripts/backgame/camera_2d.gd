extends Camera2D

@onready var player = get_tree().current_scene.get_node("ENTIDADES/player/body")
@onready var tilemap = get_tree().current_scene.get_node("NATUREZA/tileworld/solido")

var grounded_y = 0
var changing_room = false

func _physics_process(delta):

	movecamera()

func movecamera():

	var room_size = get_viewport_rect().size

	var room_x = floor(player.global_position.x / room_size.x)

	position.x = room_x * room_size.x

	var top_border = position.y
	var bottom_border = position.y + room_size.y

	# atravessou pra baixo
	if player.global_position.y > bottom_border:

		position.y += room_size.y
		changing_room = true

	# atravessou pra cima
	elif player.global_position.y < top_border:

		position.y -= room_size.y
		changing_room = true

	# aterrissou
	if changing_room and player.is_on_floor():

		if has_large_floor():

			# chão grande = câmera normal
			grounded_y = player.global_position.y + (16 * 2) - 8

		else:

			# plataforma pequena = mostra mais embaixo
			grounded_y = player.global_position.y + (16 * 10) - 8

		position.y = grounded_y - room_size.y

		changing_room = false

# =========================
# FLOOR CHECK
# =========================

func has_large_floor():

	var player_cell = tilemap.local_to_map(
		tilemap.to_local(player.global_position)
	)

	var blocks := 0

	# scan horizontal tolerante 😈
	for x in range(-2,5):

		var check = player_cell + Vector2i(x,1)

		if tilemap.get_cell_source_id(check) != -1:

			blocks += 1

	# precisa ter pelo menos 5 blocos
	return blocks >= 15
