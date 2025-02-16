extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.beat.connect(visualizer);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func visualizer() -> void:
	color = Color(1, 0, 0);
	
	await get_tree().create_timer(0.1).timeout
	
	color = Color(0, 0, 0);
