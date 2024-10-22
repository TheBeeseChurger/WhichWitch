class_name CharacterPortrait
extends TextureRect

@onready var game_screen: RhythmGameScreen = $"../.."

var base_position
var bop_strength: float = 1

func _ready():
	base_position = position

func _process(_delta: float) -> void:
	var total_beats = game_screen.dynamic_music_player.current_measure_length * 2
	var pulse_sine = abs(sin(game_screen.dynamic_music_player.t * total_beats * PI)) * bop_strength
	
	var y_add = pulse_sine*15
	var x_add = pulse_sine*10
	
	size.y = 400 + y_add
	size.x = 282 + x_add
	
	position.y = base_position.y - y_add
	position.x = base_position.x - x_add / 2
