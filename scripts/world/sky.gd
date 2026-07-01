extends Node2D

# =========================
# CONFIG
# =========================

const WORLD_SIZE = 12000

const STAR_COUNT = 4000
const CLOUD_COUNT = 120

const STAR_SPEED = 100
const DAY_SPEED = 0.03

const METEOR_PARTICLES = 6

# =========================
# CÉU ESTILO CUBE WORLD
# =========================

const DAY_COLORS = [
	Color("87CEEB"),
	Color("6EB8E8"),
	Color("5AA7DF"),
	Color("4A92D0"),
	Color("397BB8"),
	Color("2B5D93"),
	Color("1B3F6B")
]

const NIGHT_COLORS = [
	Color("060814"),
	Color("080B18"),
	Color("0B1020"),
	Color("10172B"),
	Color("17223D"),
	Color("223355"),
	Color("304A77")
]

# =========================
# DATA
# =========================

var stars := []
var clouds := []

var time := 0.0

# =========================
# READY
# =========================

func _ready():

	randomize()

	generate_stars()
	generate_clouds()

	queue_redraw()

# =========================
# STARS
# =========================

func generate_stars():

	for i in STAR_COUNT:

		stars.append({

			"pos": Vector2(
				randi_range(-WORLD_SIZE, WORLD_SIZE),
				randi_range(-WORLD_SIZE, WORLD_SIZE)
			),

			"size": randf_range(1.0, 3.0),

			"speed": randf_range(0.5, 2.0),

			"trail": [],

			"color": Color(
				randf_range(0.5, 0.8),
				randf_range(0.6, 0.9),
				1.0,
				randf_range(0.2, 1.0)
			)
		})

# =========================
# CLOUDS
# =========================

func generate_clouds():

	for i in CLOUD_COUNT:

		clouds.append({

			"pos": Vector2(
				randi_range(-WORLD_SIZE, WORLD_SIZE),
				randi_range(-WORLD_SIZE, WORLD_SIZE)
			),

			"size": Vector2(
				randi_range(200, 600),
				randi_range(60, 180)
			),

			"alpha": randf_range(0.02, 0.08)
		})

# =========================
# DRAW
# =========================

func _draw():

	var cam = get_viewport().get_camera_2d()

	if cam == null:
		return

	var screen = get_viewport_rect().size

	var cam_rect = Rect2(
		cam.global_position - screen,
		screen * 2
	)

	# =========================
	# CÉU CUBE WORLD
	# =========================

	var t = (sin(time) + 1.0) * 0.5

	var band_count = DAY_COLORS.size()
	var band_height = (WORLD_SIZE * 2.0) / band_count

	for i in band_count:

		var color = NIGHT_COLORS[i].lerp(
			DAY_COLORS[i],
			t
		)

		draw_rect(
			Rect2(
				-WORLD_SIZE,
				-WORLD_SIZE + band_height * i,
				WORLD_SIZE * 2,
				band_height + 2
			),
			color
		)

	# =========================
	# NÉVOA
	# =========================

	for c in clouds:

		if cam_rect.has_point(c.pos):

			draw_set_transform(
				c.pos,
				0.0,
				c.size / 100.0
			)

			draw_circle(
				Vector2.ZERO,
				100,
				Color(
					0.05,
					0.08,
					0.15,
					c.alpha
				)
			)

			draw_set_transform(
				Vector2.ZERO,
				0.0,
				Vector2.ONE
			)

	# =========================
	# ESTRELAS / METEOROS
	# =========================

	var star_visibility = 1.0 - t

	for s in stars:

		if cam_rect.has_point(s.pos):

			draw_circle(
				s.pos,
				s.size * 4.0,
				Color(
					s.color.r,
					s.color.g,
					s.color.b,
					0.06 * star_visibility
				)
			)

			draw_circle(
				s.pos,
				s.size,
				Color(
					1.0,
					1.0,
					1.0,
					s.color.a * star_visibility
				)
			)

			for p in s.trail:

				draw_circle(
					p.pos,
					p.size,
					Color(
						0.8,
						0.9,
						1.0,
						p.alpha * star_visibility
					)
				)

# =========================
# UPDATE
# =========================

func _process(delta):

	time += delta * DAY_SPEED

	for s in stars:

		s.pos.y += STAR_SPEED * s.speed * delta
		s.pos.x -= STAR_SPEED * 0.15 * s.speed * delta

		s.trail.append({

			"pos": s.pos,

			"size": randf_range(0.5, 2.0),

			"alpha": randf_range(0.1, 0.5)
		})

		if s.trail.size() > METEOR_PARTICLES:
			s.trail.pop_front()

		for p in s.trail:
			p.alpha -= delta * 1.5

		if s.pos.y > WORLD_SIZE:

			s.pos.y = -WORLD_SIZE
			s.pos.x = randi_range(
				-WORLD_SIZE,
				WORLD_SIZE
			)

			s.trail.clear()

	queue_redraw()
