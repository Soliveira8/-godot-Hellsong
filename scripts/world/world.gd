extends Node2D

@onready var musica = $AudioStreamPlayer
@onready var air = $AudioStreamPlayer

func _ready():
	#musica.stream = load("res://MP3/8 bit HELLSONG.mp3")
	air.stream = load("res://MP3/Erang - Dark Dungeon Synth Free Sample Pack - 45 Dark_Dungeon_TAPE_HISS_01.mp3")
	musica.play()
	air.play()
	musica.volume_linear = 1
	air.volume_linear = 0
	
	
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pass

	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
