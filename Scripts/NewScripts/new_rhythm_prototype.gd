#BRANDON SCRIPT
#NEW RHYTHM PROTOTYPE
#APPROVED BY KING JACK: False
class_name New_Rhythm
extends Control

#
#RHYTHM PROTOTYPE VARIABLES
#

#The PackedScene of the small beat bars
@export var measure_bar_scene: PackedScene;

#The PackedScene of the large measure bars
@export var staff_bar_scene: PackedScene;

#The PackedScene of the note
@export var note_scene: PackedScene;


#An array of each staff's node for spawning notes under
@onready var notes_parent: Array = [$BG/NoteBar1/Notes, $BG/NoteBar2/Notes];

#An array of each staff's node's spawn location
@onready var note_spawn: Array = [$BG/NoteBar1/NoteSpawnPoint, $BG/NoteBar2/NoteSpawnPoint];

#An array of each staff's hit indicator location
@onready var hit_spot: Array = [$BG/NoteBar1/HitSpot, $BG/NoteBar2/HitSpot];

#An array of each staff's current hit indicator's button state
var is_button_pressed: Array = [false, false];


#A current beat counter
var beat_count = 1;

#A current measure counter
var measure_count = 1;


#Returns true if the game is paused
var is_paused: bool = false;


#The text file to read from for the current song
@export var song_file_raw: String;

#The song file opened in a FileAccess
var song_file: FileAccess;

#The map of the note placements for staff 1
var song_beat_maps_1: PackedStringArray;

#The map of the note placements for staff 2
var song_beat_maps_2: PackedStringArray;

#Note placement for the current beat for staff 1
var curr_beat_map_1: String;

#Note placement for the current beat for staff 2
var curr_beat_map_2: String;

#Current index in the beat maps
var curr_map_index: int = 0;

#--------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.beat.connect(bg_spawner);
	Conductor.quarter_beat.connect(note_spawner)
	
	init_song();
	
	Conductor.play_music();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("pause") && !is_paused):
		Conductor.pause_music();
		is_paused = true;
	elif (Input.is_action_just_pressed("pause")):
		Conductor.resume_music();
		is_paused = false;
	
	if (is_paused && !Conductor.is_playing):
		return;
	elif (is_paused):
		Conductor.pause_music();
		return;
	
	staff_inputs();
	
	move_notes(delta);
	

#Bar and staff spawn manager
func bg_spawner():
	if (beat_count >= 4):
		spawn_staff_note(0);
		spawn_staff_note(1);
		
		measure_count = measure_count + 1;
		#print("Measure" + String.num(measure_count))
		beat_count = 1;
	else:
		spawn_measure_note(0);
		spawn_measure_note(1);
	
	beat_count = beat_count + 1;
	

#Note spawn manager
func note_spawner():
	if (curr_beat_map_1.length() == 0):
		read_next_beat(1);
	if (curr_beat_map_2.length() == 0):
		read_next_beat(2);
	
	var note = curr_beat_map_1[curr_map_index]; 
	
	if(note == "1"):
		spawn_note(0);
	
	note = curr_beat_map_2[curr_map_index];
	
	if(note == "1"):
		spawn_note(1);
	
	curr_map_index += 1;
	if(curr_map_index > 3):
		curr_map_index = 0;
		
		curr_beat_map_1 = "";
		curr_beat_map_2 = "";
	

#Bar spawn function
func spawn_measure_note(staff: int):
	var note = measure_bar_scene.instantiate();
	note.position = note_spawn[staff].position;
	note.rotation_degrees = -90;
	notes_parent[staff].add_child(note);
	

#Staff spawn function
func spawn_staff_note(staff: int):
	var note = staff_bar_scene.instantiate();
	note.position = note_spawn[staff].position;
	note.rotation_degrees = -90;
	notes_parent[staff].add_child(note);
	

#Note spawn function
func spawn_note(staff: int):
	var note = note_scene.instantiate();
	note.position = note_spawn[staff].position;
	note.rotation_degrees = -90;
	notes_parent[staff].add_child(note);

#Move all spawned objects based off song speed
func move_notes(delta: float):
	for i in range(0,2):
		for note in notes_parent[i].get_children():
			note.position.x = 0;
			note.position.y += 300 * (Conductor.song_speed / 100) * delta;
	

#Input manager
func staff_inputs() -> void:
	if (Input.is_action_just_pressed("proto_rhythm_press_1")):
		toggle_hitspot(0);
		is_button_pressed[0] = true;
	if (Input.is_action_just_pressed("proto_rhythm_press_2")):
		toggle_hitspot(1);
		is_button_pressed[1] = true;
	
	if (!Input.is_action_pressed("proto_rhythm_press_1") && is_button_pressed[0]):
		toggle_hitspot(0);
		is_button_pressed[0] = false;
	if (!Input.is_action_pressed("proto_rhythm_press_2") && is_button_pressed[1]):
		toggle_hitspot(1);
		is_button_pressed[1] = false;
	

#Hit indicator toggle function
func toggle_hitspot(hitspot: int):
	var perf = hit_spot[hitspot].get_node("PerfectSection");
	var okay = hit_spot[hitspot].get_node("OkaySection");
	
	perf.color = perf.color.inverted();
	okay.color = okay.color.inverted();
	

#Song initialization function
func init_song() -> void:
	song_file = FileAccess.open(song_file_raw, FileAccess.READ);
	
	song_beat_maps_1 = song_file.get_csv_line(" ");
	song_beat_maps_2 = song_file.get_csv_line(" ");

#Read next beat from Beat Map or refill Beat Map
func read_next_beat(staff: int):
	if (staff == 1):
		if (song_beat_maps_1.is_empty()):
			song_beat_maps_1 = song_file.get_csv_line(" ");
		
		if (song_beat_maps_1[0] == ""):
			curr_beat_map_1 = "1000";
			song_beat_maps_1.clear();
		
		if (!song_beat_maps_1.is_empty()):
			curr_beat_map_1 = song_beat_maps_1[0];
			
			song_beat_maps_1.remove_at(0);
	
	if (staff == 2):
		if (song_beat_maps_2.is_empty()):
			song_beat_maps_2 = song_file.get_csv_line(" ");
		
		if (song_beat_maps_2[0] == ""):
			curr_beat_map_2 = "1000";
			song_beat_maps_2.clear();
		
		if (!song_beat_maps_2.is_empty()):
			curr_beat_map_2 = song_beat_maps_2[0];
			
			song_beat_maps_2.remove_at(0);
	#print("New current beat map is: " + curr_beat_map);
