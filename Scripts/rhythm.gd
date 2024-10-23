class_name Rhythm
extends Control

@export var note_scene: PackedScene
var max_note_distance: float = 30
@export var miss_popup: PackedScene
@export var bad_popup: PackedScene
@export var okay_popup: PackedScene
@export var good_popup: PackedScene
@export var perfect_popup: PackedScene
@export var cauldron_splash_effect: PackedScene
@export var note_press_sound: AudioStream

@onready var note_miss_sound: AudioStream = preload("res://Audio/SFX/MISSSED NOTE.mp3")
@onready var note_spawn_point: Marker2D = $ColorRect/NoteSpawnPoint
@onready var target_center: Control = $ColorRect/ColorRect3/TargetCenter
@onready var popup_center: Marker2D = $ColorRect/ColorRect3/PopupCenter
@onready var tutorial_note_height_marker: Marker2D = $ColorRect/ColorRect3/TutorialNoteHeightMarker
@onready var notes_parent: Node = $Notes
@onready var cleared_notes_parent: Node = $ClearedNotes
@onready var game_screen: RhythmGameScreen = $".."
@onready var dialogue: Dialogue = $"../Dialogue"
#@onready var dynamic_music_player: DynamicMusicPlayer = $"../DynamicMusic"
@onready var cauldron: Sprite2D = $CauldronFront
@onready var note_target_visual: Sprite2D = $ColorRect/ColorRect3/TargetCenter/NoteTargetVisual

@onready var space_input_hint: Sprite2D = $ColorRect/ColorRect3/TargetCenter/SpaceInputHint
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var win_screen: WinScreen = $"../WinScreen"

var note_distance_multiplier : Dictionary = {
	"perfect" : 0.2,
	"good" : 0.45,
	"okay" : 0.7
}

var current_note_speed: float = 0 # should be 0 during cutscenes to activate intro/outro track
var notes_left: int
var time_until_next_note: float
var in_rhythm_mode = false # true while in rhythm mode

var min_speed: float = 200
var max_speed: float = 1000

var is_defeated: bool

static var tutorial_shown: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	min_speed = Level.current_level.min_speed
	max_speed = Level.current_level.max_speed
	
	# max_note_distance = something based on diffulty
	
	note_target_visual.texture = Level.current_level.note_target_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_defeated:
		return
	
	if not in_rhythm_mode:
		return
		
	if current_note_speed <= 0:
		printerr("note speed was 0 or lower!!! bad!!!")
		current_note_speed = 250
	
	if Input.is_action_just_pressed("rhythm_press"):
		if not tutorial_shown and get_tree().paused:
			tutorial_shown = true
			get_tree().paused = false
			note_target_visual.z_index = 0
			game_screen.rhythm_tutorial_panel.visible = false
			game_screen.dim_color_rect.visible = false
		else:
			rhythm_press()
			
	if get_tree().paused:
		return
	
	for note: Node2D in notes_parent.get_children():
		note.position.x = 0
		note.global_position.y += current_note_speed * delta
		
		if not tutorial_shown and note.global_position.y >= tutorial_note_height_marker.global_position.y:
			get_tree().paused = true
			game_screen.rhythm_tutorial_panel.visible = true
			game_screen.dim_color_rect.visible = true
		
		if note.global_position.y > target_center.global_position.y + max_note_distance:
			game_screen.lose_health(6)
			hit_popup(miss_popup)
			note.queue_free()
			audio_stream_player.stream = note_miss_sound
			audio_stream_player.play()
			
			if game_screen.health_bar.value <= 0:
				is_defeated = true
				notes_parent.queue_free()
				game_screen.death_animation()
				return
		
	if notes_left > 0: 
		time_until_next_note -= delta
		if time_until_next_note <= 0:
			spawn_note()
			time_until_next_note = (randf_range(0.05, 0.95) / (current_note_speed/250.0)) / Settings.difficulty_mult
			#print("time until next note: ", time_until_next_note)
			
			#var next_note_time = Time.get_unix_time_from_system() + time_until_next_note
			
			# LEAVING QUANTIZING ATTEMPT FOR LATER too much math...
			#var next_note_song_time_elapsed = next_note_time - dynamic_music.start_time
			#var beat_length = 60 / (dynamic_music.current_bpm * 4)
			#var next_beat = ceil(next_note_song_time_elapsed / beat_length) * beat_length
			#time_until_next_note = next_beat
			
			notes_left -= 1
			
	if notes_left <= 0 and notes_parent.get_child_count() == 0:
		in_rhythm_mode = false
		space_input_hint.visible = false
		dialogue.start_dialogue_mode()
		return
		
func start_rhythm_mode():
	if not in_rhythm_mode:
		visible = true
		space_input_hint.visible = true
		in_rhythm_mode = true
		notes_left = randi_range(8, 12)
		time_until_next_note = 0
		
		print("clearing ", notes_parent.get_child_count(), " nodes from notes parent")
		for child in notes_parent.get_children():
			child.queue_free()

func rhythm_press():
	var hit_type
	for note: Node2D in notes_parent.get_children():
		var distance_from_target = abs(note.global_position.y - target_center.global_position.y)
			
		if distance_from_target < max_note_distance*note_distance_multiplier["perfect"]:
			hit_type = "perfect"
			game_screen.gain_health(3)
			win_screen.add_perfect()
			hit_popup(perfect_popup)
		elif distance_from_target < max_note_distance*0.45:
			hit_type = "good"
			win_screen.add_good()
			game_screen.gain_health(2)
			hit_popup(good_popup)
		elif distance_from_target < max_note_distance*0.7:
			hit_type = "okay"
			game_screen.gain_health(1)
			win_screen.add_okay()
			hit_popup(okay_popup)
		elif distance_from_target < max_note_distance:
			hit_type = "bad"
			win_screen.add_bad()
			game_screen.gain_health(0.5)
			hit_popup(bad_popup)
		elif distance_from_target < max_note_distance*2:
			hit_type = "miss"
			win_screen.add_miss()
			game_screen.lose_health(6)
			hit_popup(miss_popup)
			if game_screen.health_bar.value <= 0:
				is_defeated = true
				notes_parent.queue_free()
				game_screen.death_animation()
				return
		
		if hit_type:
			if hit_type == "miss":
				note.queue_free()
				audio_stream_player.stream = note_miss_sound
				audio_stream_player.play()
				game_screen.apply_noise_shake()
			else:
				audio_stream_player.stream = note_press_sound
				audio_stream_player.play()
				game_screen.apply_noise_shake()
				clear_anim(note)
			return
		
func adjust_speed(speed: float):
	current_note_speed += speed
	if current_note_speed < min_speed:
		current_note_speed = min_speed
	elif current_note_speed > max_speed:
		current_note_speed = max_speed
	print("speed: ", current_note_speed)

func hit_popup(scene: PackedScene):
	var popup: Control = scene.instantiate()
	popup.global_position = popup_center.global_position
	add_child(popup)
	
	get_tree().create_tween().tween_property(popup, "modulate", Color(1,1,1,0), 1.0)
	await get_tree().create_tween().tween_property(popup, "position", popup.position + Vector2.UP*50, 1.0).finished
	
	if is_instance_valid(popup):
		popup.queue_free()

func splash_animation():
	var splash: CPUParticles2D = cauldron_splash_effect.instantiate()
	splash.global_position = cauldron.global_position
	splash.emitting = true
	add_child(splash)
	
	await get_tree().create_timer(2.0).timeout
	splash.queue_free()

func spawn_note():
	var note: Sprite2D = note_scene.instantiate()
	note.global_position = note_spawn_point.global_position
	
	var music_player := game_screen.dynamic_music_player
	
	# Song quantization
	var distance_from_target = target_center.global_position.y - note.global_position.y
	var seconds_until_on_target = distance_from_target / current_note_speed
	
	# Length of one subdivision to snap to
	var beat_length = 60 / music_player.current_bpm # Eigth note
	var total_beats = music_player.current_measure_length * 4
	
	var eigth_length = 30 / music_player.current_bpm # Eigth note
	#var total_eigths = music_player.current_measure_length * 8
	
	var inverse_t = (1-music_player.t)
	var t_until_next_subdiv: float
	var seconds_until_next_subdiv: float
	
	# only snap back only to eigth if reasonably far from next beat
	#if (inverse_t > 0.8):
		#t_until_next_subdiv = (inverse_t * total_eigths) - int(inverse_t * total_eigths)
		#seconds_until_next_subdiv = t_until_next_subdiv * eigth_length
	#else:
	t_until_next_subdiv = (inverse_t * total_beats) - int(inverse_t * total_beats)
	seconds_until_next_subdiv = t_until_next_subdiv * beat_length
	
	#var rounded_seconds_to_nearest_beat = round(seconds_until_on_target / beat_length) * beat_length
	#  + music_player.time_delay*0.5
	var adjusted_distance_from_target = (seconds_until_on_target + seconds_until_next_subdiv + music_player.time_delay) * current_note_speed
	note.global_position.y = target_center.global_position.y - adjusted_distance_from_target
	
	# check if there are any notes very close. if so, offset half a beat back
	var overlaps: bool = true
	while overlaps:
		overlaps = false
		for child: Node2D in notes_parent.get_children():
			if abs(child.global_position.y - note.global_position.y) < 15:
				overlaps = true
				break
		
		if overlaps:
			print("bump")
			note.global_position.y -= eigth_length * current_note_speed
	
	#print("spawned note at y=",note.global_position.y)
	
	# assign texture and add to notes parent node
	var note_textures = Level.current_level.note_textures
	if note_textures and len(note_textures) > 0:
		note.texture = note_textures[randi_range(0, len(note_textures)-1)]
	notes_parent.add_child(note)
	
	
	if not tutorial_shown:
		note.z_index = 3
	#print("spawned note at ", note.global_position)
	
	var interval = eigth_length * current_note_speed
	await get_tree().create_timer(0.05).timeout
	push_back_while_overlapping(note, interval)

func push_back_while_overlapping(note: Node2D, interval: float):
	var overlaps: bool = true
	var iterations: int = 50
	while overlaps:
		overlaps = false
		for child: Node2D in notes_parent.get_children():
			if note != child and abs(child.global_position.y - note.global_position.y) < 30:
				overlaps = true
				break
		
		if overlaps:
			print("bump in pushback")
			note.global_position.y -= interval
			
		iterations -= 1
		if iterations <= 0:
			print("Max bumps")
			break
	

func clear_anim(note: Sprite2D):
	note_hit_anim(note)
	
	note.reparent(cleared_notes_parent)
	note.z_index = 0
	
	get_tree().create_tween().tween_property(note, "global_position", cauldron.global_position, 0.3 / (current_note_speed/200.0))
	#get_tree().create_tween().tween_property(note, "rotation", note.rotation + deg_to_rad(randf_range(-30, 30)), 0.3 / (current_note_speed/200.0)).finished
	
	await get_tree().create_timer(0.15).timeout
	
	splash_animation()
	
	await get_tree().create_timer(0.15).timeout
	
	note.queue_free()
	
func note_hit_anim(note: Sprite2D):
	var note_hit: Sprite2D = note.duplicate()
	cleared_notes_parent.add_child(note_hit)
	note_hit.global_position = note.global_position
	
	if Level.current_level.note_hit_textures:
		note_hit.texture = Level.current_level.note_hit_textures[0]
	
	get_tree().create_tween().tween_property(note_hit, "modulate", Color(1,1,1,0), 0.3)
	await get_tree().create_tween().tween_property(note_hit, "scale", note_hit.scale*1.75, 0.3).finished
	
	note_hit.queue_free()
