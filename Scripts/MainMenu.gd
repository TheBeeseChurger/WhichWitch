extends Control

@onready var level_select: Control = $LevelSelect
@onready var credits: Control = $Credits

var level1: Level = preload("res://Levels/tutorial.tres")
var level2: Level = preload("res://Levels/nightcore.tres")
var level3: Level = preload("res://Levels/punk.tres") # metal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	credits.visible = false
	level_select.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_start_pressed():
	Rhythm.tutorial_shown = false
	play_level(level1)

func on_select_pressed():
	level_select.visible = true
	
func on_select_back_pressed():
	level_select.visible = false

func on_level_1_pressed():
	Rhythm.tutorial_shown = true
	play_level(level1)
	
func on_level_2_pressed():
	play_level(level2)
	
func on_level_3_pressed():
	play_level(level3)
	
func play_level(level: Level):
	Level.current_level = level
	get_tree().change_scene_to_file("res://Scenes/rhythm_game_screen.tscn")

func on_credits_pressed():
	credits.visible = true
	
func on_credits_back_pressed():
	credits.visible = false
