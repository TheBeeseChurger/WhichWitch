#BRANDON SCRIPT
#NEW CHARACTER PORTRAIT PROTOTYPE
#APPROVED BY KING JACK: False
class_name NewCharacterPortrait
extends TextureRect

#
#CHARACTER PORTRAIT VARIABLES
#

#Original width of portrait
@onready var base_width = size.x

#Original height of portrait
@onready var base_height = size.y

#Original position of portrait
@onready var base_position = position


#Strength of the bop effect
var bop_strength: float = 1

#--------------------------------------------------------

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pulse = sin(Conductor.song_speed * PI) * bop_strength;
	
	var y_add = pulse * 15;
	var x_add = pulse * 10;
	
	size.y = base_height + y_add;
	size.x = base_width + x_add;
	
	position.y = base_position.y - y_add;
	position.x = base_position.x - x_add / 2;
