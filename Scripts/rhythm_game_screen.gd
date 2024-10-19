class_name RhythmGameScreen
extends MarginContainer

# Health is stored in this bar
@onready var health_bar: TextureProgressBar = $HealthBar




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
