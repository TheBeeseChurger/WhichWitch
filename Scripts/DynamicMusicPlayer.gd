class_name DynamicMusicPlayer
extends AudioStreamPlayer

@export var audio_streams: Array[AudioStream]
@export var intensity_speeds: Array[float]
@export var divisions: Array[int]
@export var bpms: Array[float]
@export var transition_audio_streams: Array[AudioStream]

@onready var rhythm: Rhythm = $"../Rhythm"

var current_track_index: int = -1
var current_division: int = 0
var current_bpm: float

var start_time: float

var in_transition_track: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_next_track()
	start_time = Time.get_unix_time_from_system()
	finished.connect(on_finished)
	
func _process(delta: float) -> void:
	var t := get_playback_position() / stream.get_length()
	
	if not in_transition_track:
		var total_divisions = divisions[current_track_index]
		var new_division = floor(t * total_divisions)
		
		if new_division > current_division:
			var play = new_division >= total_divisions
			play_next_track(play)
			if new_division >= total_divisions:
				new_division -= total_divisions
			
		current_division = new_division
	
func on_finished():
	play_next_track(true)

# play next track if a transition needs to happen. if not, keep playing the current track
func play_next_track(play: bool = true):
	var next_track_index = len(intensity_speeds)-1
	for i in range(0, len(intensity_speeds)):
		var speed = intensity_speeds[i]
		if rhythm.current_note_speed <= speed:
			next_track_index = i
			break
	
	if next_track_index != current_track_index or in_transition_track:
		print("switching from track ", current_track_index, " to ", next_track_index)
		current_track_index = next_track_index
		var transition_stream: AudioStream = transition_audio_streams[current_track_index]
		if transition_stream and not in_transition_track:
			stream = transition_stream
			in_transition_track = true
			current_bpm = 0
		else:
			stream = audio_streams[current_track_index]
			in_transition_track = false
			current_bpm = bpms[current_track_index]
		
		
		start_time = Time.get_unix_time_from_system()
		self.play()
		return
	else:
		#print("looped! current division: ", current_division)
		pass

	if play:
		start_time = Time.get_unix_time_from_system()
		current_bpm = bpms[current_track_index]
		self.play()
