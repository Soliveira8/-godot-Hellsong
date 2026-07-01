extends CanvasLayer

# =========================
# CONFIG
# =========================

@export var fps_color := Color.GREEN
@export var update_speed := 0.1



# tua fonte custom 😈
@export var custom_font : FontFile = preload("res://voxel1.ttf")

@onready var player = get_tree().current_scene.get_node("ENTIDADES/player/body")


# =========================
# DATA
# =========================

var fps_label : Label
var stateplayer_label : Label
var timer := 0.0

# =========================
# READY
# =========================

func _ready():


	stateplayer_label = Label.new()
	fps_label = Label.new()

	add_child(fps_label)
	add_child(stateplayer_label)

	# posição
	fps_label.position = Vector2(10,10)
	
	
	fps_label.scale = Vector2(0.4,0.4)
	stateplayer_label.scale = Vector2(0.4,0.4)

	# cor
	fps_label.modulate = fps_color
	stateplayer_label.modulate = Color.WHITE

	# fonte custom
	if custom_font:

		fps_label.add_theme_font_override(
			"font",
			custom_font
		)
		stateplayer_label.add_theme_font_override(
			"font",
			custom_font
		)
		

# =========================
# PROCESS
# =========================

func _process(delta):
	var playerloc = player.global_position - get_viewport().get_camera_2d().global_position
	printscreen(delta,player.direction,Vector2(0.4,0.4),Color.HONEYDEW,playerloc,"teste1",false)
	
	
	
	
	
	
	stateplayer_label.position = playerloc - Vector2(5,30)
	timer += delta

	if timer >= update_speed:

		timer = 0.0

		var fps = Engine.get_frames_per_second()

		fps_label.text = "FPS: " + str(fps)
		stateplayer_label.text = str(player.states.keys()[player.state])

		# cores debug ☠️
		if fps < 30:

			fps_label.modulate = Color.RED

		elif fps < 60:

			fps_label.modulate = Color.YELLOW

		else:

			fps_label.modulate = fps_color


func printscreen(delta, text, size, color, position, label_name, aways):
	
	if aways == false:
		if not has_node(label_name):
			
			var label = Label.new()
			label.name = label_name
			add_child(label)

			label.position = position
			label.scale = size
			label.modulate = color
			label.text = str(text)
			
			if custom_font:
				label.add_theme_font_override(
					"font",
					custom_font
				)
		if has_node(label_name):
			var label = get_node(label_name)
			
			label.position = position
			label.scale = size
			label.modulate = color
			label.text = str(text)
