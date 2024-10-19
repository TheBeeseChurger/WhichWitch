class_name RhythmGameScreen
extends Control

# current level being played
@export var level: Level

# Health is stored in this bar
@onready var health_bar: TextureProgressBar = $HealthMarginContainer/HealthBar

var dynamic_music_player: DynamicMusicPlayer

@onready var opponent_portrait: TextureRect = $PortraitContainer/OpponentPortrait
@onready var player_portrait: TextureRect = $PortraitContainer/PlayerPortrait


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Level.current_level = level
	dynamic_music_player = $DynamicMusicPlayer
	dynamic_music_player.dynamic_music = level.dynamic_music
	dynamic_music_player.play_next_track()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func gain_health(amount: float):
	health_bar.value += amount
	
func lose_health(amount: float):
	health_bar.value -= amount
