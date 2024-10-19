class_name RhythmGameScreen
extends Control

# Health is stored in this bar
@onready var health_bar: TextureProgressBar = $HealthBar

@onready var p1_portrait: TextureRect = $PortraitContainer/P1Portrait
@onready var p2_portrait: TextureRect = $PortraitContainer/P2Portrait



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func gain_health(amount: float):
	health_bar.value += amount
	
func lose_health(amount: float):
	health_bar.value -= amount
