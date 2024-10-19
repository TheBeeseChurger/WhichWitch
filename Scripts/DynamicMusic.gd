extends AudioStreamPlayer

@export var audio_streams: Array[AudioStream]
@export var intensity_speeds: Array[float]
@export var bpms: Array[float]

@onready var rhythm: Rhythm = $"../Rhythm"

var current_track_index: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_next_track()
	self.finished.connect(play_next_track)

func play_next_track():
	var next_track_index = len(intensity_speeds)-1
	for i in range(0, len(intensity_speeds)):
		var speed = intensity_speeds[i]
		if rhythm.current_note_speed <= speed:
			next_track_index = i
			break
	
	if next_track_index != current_track_index:
		print("switching from track ", current_track_index, " to ", next_track_index)
		current_track_index = next_track_index
		stream = audio_streams[current_track_index]
	else:
		print("looped!")
	
	self.play()
