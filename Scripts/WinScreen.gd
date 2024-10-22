class_name WinScreen
extends Control

@export var rank_colors: Array[Color]

@onready var game_screen: RhythmGameScreen = $".."

@onready var rank_label: Label = $VBoxContainer/RankRow/RankLabel
@onready var score_label: Label = $VBoxContainer/ScoreRow/Label
@onready var accuracy_label: Label = $VBoxContainer/AccuracyRow/Label
@onready var perfect_label: Label = $VBoxContainer/PerfectRow/Label
@onready var good_label: Label = $VBoxContainer/GoodRow/Label
@onready var okay_label: Label = $VBoxContainer/OkayRow/Label
@onready var bad_label: Label = $VBoxContainer/BadRow/Label
@onready var miss_label: Label = $VBoxContainer/MissRow/Label
@onready var next_button: Button = $NextButton
@onready var game_win_label: Label = $GameWinLabel

@onready var cutscene: Cutscene = $"../Cutscene"

@onready var rhythm: Rhythm = $"../Rhythm"
@onready var dialogue: Dialogue = $"../Dialogue"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var total_notes: int

var points: int = 0:
	set(value):
		points = value
		game_screen.points_label.text = str(points)

var perfect := 0
var good := 0
var okay := 0
var bad := 0
var miss := 0

func add_perfect():
	total_notes += 1
	perfect += 1
	points += 40
	
func add_good():
	total_notes += 1
	good += 1
	points += 30
	
func add_okay():
	total_notes += 1
	okay += 1
	points += 20
	
func add_bad():
	total_notes += 1
	bad += 1
	points += 10

func add_miss():
	total_notes += 1
	miss += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func show_win_screen():
	visible = true
	
	cutscene.npc_dialogue_box.visible = false
	
	game_screen.rhythm_tutorial_panel
	
	rhythm.set_process(false)
	rhythm.in_rhythm_mode = false
	cutscene.set_process(false)
	dialogue.queue_free()
	
	var accuracy: float = (total_notes - miss) / float(total_notes)
	
	var thresholds = Level.current_level.rank_thresholds
	var rank: String
	var color: Color
	if points >= thresholds[0]:
		rank = "S"
		color = rank_colors[0]
	elif points >= thresholds[1]:
		rank = "A"
		color = rank_colors[1]
	elif points >= thresholds[2]:
		rank = "B"
		color = rank_colors[2]
	elif points >= thresholds[3]:
		rank = "C"
		color = rank_colors[3]
	elif points >= thresholds[4]:
		rank = "D"
		color = rank_colors[4]
	else:
		rank = "F"
		color = rank_colors[5]

	rank_label.text = rank
	rank_label.label_settings.outline_color = color
	score_label.text = str(points)
	accuracy_label.text = ('%.2f' % (accuracy*100)) + "%"
	
	perfect_label.text = str(perfect)
	good_label.text = str(good)
	okay_label.text = str(okay)
	bad_label.text = str(bad)
	miss_label.text = str(miss)

func next_level_pressed():
	Level.current_level = Level.current_level.next_level
	game_screen.retry_pressed()
