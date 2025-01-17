#BRANDON SCRIPT
#NEW RHYTHM PROTOTYPE
#APPROVED BY KING JACK: False
class_name New_Rhythm
extends Control

@export var measure_bar_scene: PackedScene;
@export var staff_bar_scene: PackedScene;

@onready var notes_parent: Array = [$NoteBar1/Notes, $NoteBar2/Notes];
@onready var note_spawn: Array = [$NoteBar1/NoteSpawnPoint, $NoteBar2/NoteSpawnPoint];
@onready var hit_spot: Array = [$NoteBar1/HitSpot, $NoteBar2/HitSpot];
var is_button_pressed: Array = [false, false];

var beat_count = 0;
var measure_count = 0;

var is_paused: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.beat.connect(spawner);
	
	Conductor.play_music();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("pause") && !is_paused):
		Conductor.pause_music();
		is_paused = true;
	elif (Input.is_action_just_pressed("pause")):
		Conductor.resume_music();
		is_paused = false;
	
	if (is_paused):
		return;
		
	
	staff_inputs();
	
	move_notes(delta);
	

func spawner():
	beat_count = beat_count - 1;
	
	if (beat_count <= 0):
		spawn_staff_note(0);
		spawn_staff_note(1);
		
		measure_count = measure_count + 1;
		#print("Measure" + String.num(measure_count))
		beat_count = 4;
	else:
		spawn_measure_note(0);
		spawn_measure_note(1);
	

func spawn_measure_note(staff: int):
	var note = measure_bar_scene.instantiate();
	note.position = note_spawn[staff].position;
	note.rotation_degrees = -90;
	notes_parent[staff].add_child(note);
	

func spawn_staff_note(staff: int):
	var note = staff_bar_scene.instantiate();
	note.position = note_spawn[staff].position;
	note.rotation_degrees = -90;
	notes_parent[staff].add_child(note);
	

func move_notes(delta: float):
	for i in range(0,2):
		for note in notes_parent[i].get_children():
			note.position.x = 0;
			note.position.y += Conductor.song_speed * delta;
	

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
	

func toggle_hitspot(hitspot: int):
	var perf = hit_spot[hitspot].get_node("PerfectSection");
	var okay = hit_spot[hitspot].get_node("OkaySection");
	
	perf.color = perf.color.inverted();
	okay.color = okay.color.inverted();
	
