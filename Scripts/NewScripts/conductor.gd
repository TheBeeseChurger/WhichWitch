#BRANDON SCRIPT
#NEW CONDUCTOR PROTOTYPE
#APPROVED BY KING JACK: False
extends Node

#
#CONDUCTOR VARIABLES
#

#Returns true if currently conducting
var is_conducting: bool = false;

#Returns true if song_pos is positive
var is_playing: bool = false;


#Song beats per minute (each beat is an eighth note)
@export var song_bpm: float;

#Current speed of the song
@export var song_speed: float = 1.00;


#Distance between the spawn point and the hit point
@export var travel_dist: float;

#Delay for notes to travel across the screen
var travel_delay: float;

#Delay for latency reasons, changed in settings (WIP)
@export var latency_delay : float;

#Delay for song start to account for song intro
var start_delay: float = 3.0;


#Number of seconds per song beat
var sec_per_beat: float;

#Current song positon, in seconds
var song_pos: float;

#Current song position, in beats
var song_pos_in_beats: float = -999;

#Seconds passed since song started
var song_start_time: float;

#First beat offset, in seconds
@export var first_beat_offset: float;


#Current beat count
var beat_count: int = 0;

#Current measure count
var measure_count: int = 0;


#AudioStreamPlayer where the song will play
@onready var music_player: AudioStreamPlayer = $".";


#Signal to alert for measure (Whole Notes)
signal measure;

#Signal to alert for beat (Quarter Notes)
signal beat;

#Signal to alert for half-beat (Eighth Notes)
signal half_beat;

#Signal to alert for quarter-beat (Sixteenth Notes)
signal quarter_beat;

#--------------------------------------------------------

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	set_process(is_conducting);

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(_delta: float) -> void:
	if(get_tree().paused):
		return;
	
	if (travel_delay != travel_dist / song_speed):
		travel_delay = travel_dist / song_speed;
	
	song_pos = (float((Time.get_ticks_msec() / 1000.0) - song_start_time) - first_beat_offset - travel_delay - latency_delay - start_delay);
	
	if (song_pos_in_beats == -999):
		song_pos_in_beats = song_pos / sec_per_beat;
		
		var time_diff = abs(song_pos_in_beats - floor(song_pos_in_beats)) * sec_per_beat;
		
		song_start_time -= time_diff;
		
		song_pos = (float((Time.get_ticks_msec() / 1000.0) - song_start_time - first_beat_offset) - travel_delay - latency_delay - start_delay);
		song_pos_in_beats = song_pos / sec_per_beat;
	
	var old_measure: int = ceil(song_pos_in_beats / 4) if song_pos_in_beats > 0 else floor(song_pos_in_beats / 4);
	var old_beat: int = ceil(song_pos_in_beats) if song_pos_in_beats > 0 else floor(song_pos_in_beats);
	var old_half: int = ceil(song_pos_in_beats * 2) if song_pos_in_beats > 0 else floor(song_pos_in_beats * 2);
	var old_quarter: int = ceil(song_pos_in_beats * 4) if song_pos_in_beats > 0 else floor(song_pos_in_beats * 4);
	
	song_pos_in_beats = song_pos / sec_per_beat;
	if (old_measure != (ceil(song_pos_in_beats / 4) if song_pos_in_beats > 0 else floor(song_pos_in_beats / 4))):
		measure.emit();
		
		if(song_pos > 0):
			measure_count += 1;
		#print("measure emitted at " + String.num(song_pos_in_beats));
	if (old_beat != (ceil(song_pos_in_beats) if song_pos_in_beats > 0 else floor(song_pos_in_beats))):
		if (!music_player.is_playing() && song_pos > 0):
			is_playing = true;
			music_player.play();
		
		beat.emit();
		#print("beat emitted at " + String.num(song_pos_in_beats));
	if (old_half != (ceil(song_pos_in_beats * 2) if song_pos_in_beats > 0 else floor(song_pos_in_beats * 2))):
		half_beat.emit();
		#print("half beat emitted at " + String.num(song_pos_in_beats));
	if (old_quarter != (ceil(song_pos_in_beats * 4) if song_pos_in_beats > 0 else floor(song_pos_in_beats * 4))):
		quarter_beat.emit();
		#print("quarter beat emitted at " + String.num(song_pos_in_beats));
	
	

#Starts song at beginning
func play_music() -> void:
	song_start_time = (Time.get_ticks_msec() / 1000.0);
	sec_per_beat = 60.0 / song_bpm;
	set_process(true);
	is_conducting = true;
	

#Continues song from current position
func resume_music() -> void:
	song_start_time = (Time.get_ticks_msec() / 1000.0) - song_pos;
	set_process(true);
	is_conducting = true;
	

#Pauses song at current position
func pause_music() -> void:
	music_player.stop();
	set_process(false);
	is_conducting = false;
	is_playing = false;
	
