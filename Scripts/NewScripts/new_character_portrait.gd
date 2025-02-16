#BRANDON SCRIPT
#NEW CHARACTER PORTRAIT PROTOTYPE
#APPROVED BY KING JACK: False
class_name NewCharacterPortrait
extends TextureRect

#
#CHARACTER PORTRAIT VARIABLES
#

#Original width of portrait
@onready var base_width = size.x;

#Original height of portrait
@onready var base_height = size.y;

#Original position of portrait
@onready var base_position = position;


#Strength of the bop effect
var bop_strength: float = 0.4;

#--------------------------------------------------------

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var pulse = abs(sin(((Conductor.song_bpm / 60.0) / 2 * Conductor.song_pos) * PI)) * bop_strength;
	
	var y_add = pulse * 15;
	var x_add = pulse * 10;
	
	size.y = base_height + y_add;
	size.x = base_width + x_add;
	
	position.y = base_position.y - y_add;
	position.x = base_position.x - x_add / 2;
