extends Control

@onready var credits: Control = $Credits


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/rhythm_game_screen.tscn")

func on_credits_pressed():
	credits.visible = true
	
func on_credits_back_pressed():
	credits.visible = false
