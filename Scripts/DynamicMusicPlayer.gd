class_name DynamicMusicPlayer
extends AudioStreamPlayer

@onready var rhythm: Rhythm = $"../Rhythm"

var dynamic_music: DynamicMusic

var current_track_index: int = -1
var current_division: int = 0
var current_bpm: float
var current_measure_length: float

var start_time: float

var in_transition_track: bool

var t: float

# -1 = no forced
# -2 = will stop after current loop
var forced_transition: int = -1

#var time_begin
var time_delay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time = Time.get_unix_time_from_system()
	finished.connect(on_finished)
	
	#time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_output_latency()
	
func _process(_delta: float) -> void:
	t = get_playback_position() / stream.get_length()
	
	if in_transition_track:
		current_bpm = lerp(dynamic_music.bpms[current_track_index-1], dynamic_music.bpms[current_track_index], t)
	
	if not in_transition_track and forced_transition != -1:
		var total_divisions = dynamic_music.divisions[current_track_index]
		var new_division = floor(t * total_divisions)
		
		if new_division > current_division:
			var play_track = new_division >= total_divisions
			play_next_track(play_track)
			if new_division >= total_divisions:
				new_division -= total_divisions
			
		current_division = new_division
	
func on_finished():
	play_next_track(true)

# play next track if a transition needs to happen. if not, keep playing the current track
func play_next_track(_play: bool = true):
	var next_track_index = len(dynamic_music.intensity_speeds)-1
	
	for i in range(0, len(dynamic_music.intensity_speeds)):
		var speed = dynamic_music.intensity_speeds[i]
		if rhythm.current_note_speed <= speed:
			next_track_index = i
			break
	
	if forced_transition != -1:
		if forced_transition == -2:
			volume_db = -100
			stop()
			queue_free()
			return
		else:
			next_track_index = forced_transition
			forced_transition = -1
	
	if next_track_index != current_track_index or in_transition_track:
		print("switching from track ", current_track_index, " to ", next_track_index)
		current_track_index = next_track_index
		var transition_stream: AudioStream = dynamic_music.transition_audio_streams[current_track_index]
		
		if transition_stream and not in_transition_track:
			stream = transition_stream
			in_transition_track = true
			current_measure_length = dynamic_music.transition_meausure_lengths[current_track_index]
		else:
			stream = dynamic_music.audio_streams[current_track_index]
			in_transition_track = false
			current_bpm = dynamic_music.bpms[current_track_index]		
			current_measure_length = dynamic_music.meausure_lengths[current_track_index]
			
		if len(dynamic_music.force_transition_at_end) > current_track_index:
			var check_forced: int = dynamic_music.force_transition_at_end[current_track_index]
			if check_forced == -1:
				pass
			else:
				forced_transition = check_forced
		
		start_time = Time.get_unix_time_from_system()
		self.play()
		time_delay = AudioServer.get_output_latency()
		return
	else:
		#print("looped! current division: ", current_division)
		pass

	if play:
		start_time = Time.get_unix_time_from_system()
		current_bpm = dynamic_music.bpms[current_track_index]
		self.play()
