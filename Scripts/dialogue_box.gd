class_name DialogueBox
extends Panel

@export var characters_per_second: float = 40.0

@export var linger_time = 2.5

var showing: bool
var full_message: String
var current_index: int = 0
var time_passed: float = 0.0

var typing: bool

@onready var label: Label = $Label

signal line_finished

func show_message(message: String):
	visible = true
	showing = true
	typing = true
	full_message = message
	current_index = 0
	time_passed = 0
	label.text = ""

func show_full_line():
	label.text = full_message
	current_index = len(full_message)
	typing = false
	line_finished.emit()

func _process(delta: float) -> void:
	if not showing:
		return
	
	# Calculate how much time has passed and how many characters to show
	time_passed += delta
	var chars_to_show = int(time_passed * characters_per_second)

	# Update the text if we haven't reached the end
	if current_index < full_message.length():
		label.text = full_message.substr(0, min(chars_to_show, full_message.length()))
		current_index = chars_to_show
	else:
		if typing:
			typing = false
			line_finished.emit()
