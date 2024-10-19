class_name Rhythm
extends Control

@export var note_speed: float = 200
@export var note_scene: PackedScene
@export var max_note_distance: float = 50

@onready var note_spawn_point: Marker2D = $ColorRect/NoteSpawnPoint
@onready var notes_parent: Node = $Notes
@onready var target_center: Marker2D = $ColorRect/TargetCenter

@onready var dialogue: Dialogue = $"../Dialogue"

var notes_left: int
var time_until_next_note: float

var in_rhythm_mode = false # true while in rhythm mode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_rhythm_mode()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not in_rhythm_mode:
		return
	
	if Input.is_action_just_pressed("rhythm_press"):
		rhythm_press()
	
	for note: Node2D in notes_parent.get_children():
		note.global_position.y += note_speed * delta
		if note.global_position.y > target_center.global_position.y + max_note_distance:
			# note went past the target, it was missed, take damage
			note.queue_free()
		
	if notes_left > 0:
		time_until_next_note -= delta
		if time_until_next_note < 0:
			spawn_note()
			time_until_next_note = randf_range(0.25, 1.0)
			notes_left -= 1
			
	if notes_left <= 0 and notes_parent.get_child_count() == 0:
		in_rhythm_mode = false
		dialogue.start_dialogue_mode()
		return
		
func start_rhythm_mode():
	if not in_rhythm_mode:
		in_rhythm_mode = true
		notes_left = 3

func rhythm_press():
	for note: Node2D in notes_parent.get_children():
		var distance_from_target = abs(note.global_position.y - target_center.global_position.y)
		if distance_from_target < max_note_distance:
			# note was hit successfully, gain some health based on how close it was to the target
			note.queue_free()
			return
			
	# if code reaches here, no note cleared on press, take damage or something

func spawn_note():
	var note: Node2D = note_scene.instantiate()
	note.global_position = note_spawn_point.global_position
	notes_parent.add_child(note)
	print("spawned note at ", note.global_position)
