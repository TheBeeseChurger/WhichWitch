class_name Rhythm
extends Control

@export var starting_speed: float = 300
@export var min_speed: float = 200
@export var starting_speed: float = 1000
@export var note_scene: PackedScene
@export var max_note_distance: float = 50

@export var miss_popup: PackedScene
@export var bad_popup: PackedScene
@export var okay_popup: PackedScene
@export var good_popup: PackedScene
@export var great_popup: PackedScene

@onready var note_spawn_point: Marker2D = $ColorRect/NoteSpawnPoint
@onready var target_center: Marker2D = $ColorRect/TargetCenter
@onready var popup_center: Marker2D = $ColorRect/PopupCenter
@onready var notes_parent: Node = $Notes

@onready var game_screen: RhythmGameScreen = $".."
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
			# MISS
			game_screen.lose_health(5)
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
		notes_left = 5

func rhythm_press():
	var hit_type
	for note: Node2D in notes_parent.get_children():
		var distance_from_target = abs(note.global_position.y - target_center.global_position.y)
			
		if distance_from_target < max_note_distance*0.15:
			hit_type = "great"
			game_screen.gain_health(3)
			hit_popup(great_popup)
		elif distance_from_target < max_note_distance*0.35:
			hit_type = "good"
			game_screen.gain_health(2)
			hit_popup(good_popup)
		elif distance_from_target < max_note_distance*0.65:
			hit_type = "okay"
			game_screen.gain_health(1)
			hit_popup(okay_popup)
		elif distance_from_target < max_note_distance:
			hit_type = "bad"
			hit_popup(bad_popup)
		elif distance_from_target < max_note_distance*2:
			hit_type = "miss"
			game_screen.lose_health(6)
			hit_popup(miss_popup)
		
		if hit_type:
			note.queue_free()
			return
		
func set_speed(speed: float):
	note_speed = speed

func hit_popup(scene: PackedScene):
	var popup: Control = scene.instantiate()
	popup.global_position = popup_center.global_position
	add_child(popup)
	
	get_tree().create_tween().tween_property(popup, "modulate", Color(1,1,1,0), 1.0)
	await get_tree().create_tween().tween_property(popup, "position", popup.position + Vector2.UP*50, 1.0).finished
	
	if is_instance_valid(popup):
		popup.queue_free()

func spawn_note():
	var note: Node2D = note_scene.instantiate()
	note.global_position = note_spawn_point.global_position
	notes_parent.add_child(note)
	print("spawned note at ", note.global_position)
