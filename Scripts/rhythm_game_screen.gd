class_name RhythmGameScreen
extends Control

const SHAKE_INTENSITY: float = 20.0

# current level being played
@export var level: Level



# Health is stored in this bar
@onready var health_bar: TextureProgressBar = $HealthMarginContainer/HealthBar

var dynamic_music_player: DynamicMusicPlayer

@onready var opponent_portrait: TextureRect = $PortraitContainer/OpponentPortrait
@onready var player_portrait: TextureRect = $PortraitContainer/PlayerPortrait

@onready var background: TextureRect = $Background

var shake_duration: float = 0.5
var shake_duration_remaining: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Level.current_level = level
	opponent_portrait.texture = level.neutral_sprite
	dynamic_music_player = $DynamicMusicPlayer
	dynamic_music_player.dynamic_music = level.dynamic_music
	dynamic_music_player.play_next_track()
	background.texture = level.background_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_duration_remaining > 0:
		shake_duration_remaining = move_toward(shake_duration_remaining, 0, delta)
	
func shake():
	shake_duration_remaining = shake_duration
	
func gain_health(amount: float):
	health_bar.value += amount
	
func lose_health(amount: float):
	health_bar.value -= amount
