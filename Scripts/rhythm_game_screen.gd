class_name RhythmGameScreen
extends Control

# Health is stored in this bar
@onready var health_bar: TextureProgressBar = $HealthBar

var dynamic_music_player: DynamicMusicPlayer

@onready var opponent_portrait: CharacterPortrait = $PortraitContainer/OpponentPortrait
@onready var player_portrait: CharacterPortrait = $PortraitContainer/PlayerPortrait

@onready var background: TextureRect = $Background
@onready var dim_color_rect: ColorRect = $DimColorRect

@onready var rhythm_tutorial_panel: PanelContainer = $Rhythm/RhythmTutorialPanel
@onready var dialogue_tutorial_panel: PanelContainer = $Dialogue/DialogueTutorialPanel

@onready var death_screen: Control = $DeathScreen
@onready var pause_menu: Control = $PauseMenu


# How quickly to move through the noise
const NOISE_SHAKE_SPEED: float = 5.0
# Noise returns values in the range (-1, 1)
# So this is how much to multiply the returned value by
const NOISE_SHAKE_STRENGTH: float = 15.0
# Multiplier for lerping the shake strength to zero
const SHAKE_DECAY_RATE: float = 4.0
@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()

# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var noise_i: float = 0.0

var shake_strength: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opponent_portrait.texture = Level.current_level.neutral_sprite
	dynamic_music_player = $DynamicMusicPlayer
	dynamic_music_player.dynamic_music = Level.current_level.dynamic_music
	dynamic_music_player.play_next_track()
	background.texture = Level.current_level.background_texture
	
	rand.randomize()
	# Randomize the generated noise
	noise.seed = rand.randi()
	# Period affects how quickly the noise changes values
	noise.frequency = 0.5
	
	rhythm_tutorial_panel.visible = false
	dialogue_tutorial_panel.visible = false
	dim_color_rect.visible = false
	death_screen.visible = false
	pause_menu.visible = false

func _process(delta: float) -> void:	
	# Fade out the intensity over time
	shake_strength = move_toward(shake_strength, 0.0, NOISE_SHAKE_STRENGTH * SHAKE_DECAY_RATE * delta)

	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	position = get_noise_offset(delta)

func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)

func apply_noise_shake() -> void:
	shake_strength = NOISE_SHAKE_STRENGTH
	
func gain_health(amount: float):
	health_bar.value += amount
	
func lose_health(amount: float):
	health_bar.value -= amount
	
func death_animation():
	dim_color_rect.visible = true
	dim_color_rect.modulate = Color(1,1,1,0)
	
	dynamic_music_player.volume_db = -100
	
	death_screen.visible = true
	
	get_tree().paused = true
	
func retry_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/rhythm_game_screen.tscn")

func home_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/title-screen.tscn")

func pause_opened():
	get_tree().paused = true
	pause_menu.visible = true
	
func pause_closed():
	get_tree().paused = false
	pause_menu.visible = false
