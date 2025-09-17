extends Control
@onready var v_box_container: VBoxContainer = $VBoxContainer

@onready var level_select: Control = $LevelSelect
@onready var credits: Control = $Credits
@onready var difficulty_button : Button = $VBoxContainer/DifficultyButton

var level1: Level = preload("res://Levels/tutorial.tres")
var level2: Level = preload("res://Levels/nightcore.tres")
var level3: Level = preload("res://Levels/punkgirl.tres")
var test_level: Level = preload("res://Levels/test.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	credits.visible = false
	level_select.visible = false
	RhythmGameScreen.is_female = randf() >= 0.5
	
	difficulty_button.text = "Difficulty: " + Settings.get_difficulty_string()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_start_pressed():
	Rhythm.tutorial_shown = false
	play_level(level1)

func on_select_pressed():
	v_box_container.visible = false
	level_select.visible = true
	
func on_select_back_pressed():
	v_box_container.visible = true
	level_select.visible = false

func on_level_1_pressed():
	Rhythm.tutorial_shown = true
	play_level(level1)
	
func on_level_2_pressed():
	play_level(level2)
	
func on_level_3_pressed():
	play_level(level3)
	
func on_test_level_pressed():
	play_level(test_level)
	
func play_level(level: Level):
	Level.current_level = level
	get_tree().change_scene_to_file("res://Scenes/rhythm_game_screen.tscn")

func on_credits_pressed():
	v_box_container.visible = false
	credits.visible = true
	
func on_credits_back_pressed():
	v_box_container.visible = true
	credits.visible = false
	
func on_quit_pressed():
	get_tree().quit()

func on_difficulty_pressed() -> void:
	Settings.bump_difficulty()
	difficulty_button.text = "Difficulty: " + Settings.get_difficulty_string()
