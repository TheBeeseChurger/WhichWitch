class_name Dialogue
extends Control

@export var dialogue_option_scene: PackedScene
@export var good_rating_texture: Texture2D
@export var meh_rating_texture: Texture2D
@export var bad_rating_texture: Texture2D

@onready var npc_dialogue_box: DialogueBox = $NpcDialogueBox
@onready var respond_time_left_bar: TextureProgressBar = $NpcDialogueBox/RespondTimeLeftBar
@onready var random_popup_container: Control = $RandomPopupContainer
@onready var rhythm: Rhythm = $"../Rhythm"
@onready var rating_anim_rect: TextureRect = $"../PortraitContainer/OpponentPortrait/RatingAnimRect"
@onready var cutscene: Cutscene = $"../Cutscene"



# Contains all dialogue
var dialogue: Dictionary
var questions: Array

var current_question_index: int = -1

# current question the opponent is asking
var current_question: Dictionary

# list of indexes for reply options to the current question.
var dialogue_options_queued: Array[int]

# used for randomly queueing question reply options
var time_until_next_option: float

# true while in dialogue mode and not in rhythm mode
var in_dialogue_mode = false

# time remaining to answer the current question
var respond_time_remaining: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	npc_dialogue_box.visible = false
	
	rating_anim_rect.modulate = Color(1,1,1,0)
	
	var dialogue_file = FileAccess.open("res://Dialogue/tutorial_character.json", FileAccess.READ)
	var json_string = dialogue_file.get_as_text()
	dialogue_file.close()
	var json = JSON.new()
	json.parse(json_string)
	dialogue = json.data
	questions = dialogue["questions"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not in_dialogue_mode:
		return
		
	time_until_next_option -= delta
	if time_until_next_option <= 0:
		if len(dialogue_options_queued) > 0:
			spawn_random_option()
			time_until_next_option = randf_range(0.25, 1.0)
		
	respond_time_remaining -= delta
	if respond_time_remaining <= 0:
		submit_dialogue({})
		respond_time_remaining = 10000.0
	else:
		respond_time_left_bar.value = respond_time_remaining

func start_dialogue_mode():
	if in_dialogue_mode:
		return
		
	# choose the next question to ask
	current_question_index += 1
	if current_question_index >= len(questions):
		visible = false
		rhythm.current_note_speed = 0
		cutscene.play_outro_cutscene()
		return
	
	current_question = questions[current_question_index];
		
	npc_dialogue_box.show_message(current_question["text"])
	in_dialogue_mode = true
	dialogue_options_queued = []
	for i in range(len(current_question["replies"])):
		dialogue_options_queued.append(i)
	if current_question.has("time"):
		respond_time_remaining = current_question["time"]
	else:
		respond_time_remaining = 10.0
	
	respond_time_left_bar.max_value = respond_time_remaining

func spawn_random_option():
	var i = randi_range(0, len(dialogue_options_queued)-1)
	var option_index = dialogue_options_queued.pop_at(i)
	#print(dialogue_options_queued)
	var reply: Dictionary = current_question["replies"][option_index]
	var option: Button = dialogue_option_scene.instantiate()
	option.text = reply["text"]
	option.pressed.connect(func(): submit_dialogue(reply))
	
	var random_x: int = 0
	var random_y: int = 0
	
	option.position = Vector2(random_x, random_y)
	
	var iteration_max: int = 50
	
	var intersects: bool = true
	while intersects:
		random_x = randi_range(0, random_popup_container.size.x - option.size.x)
		random_y = randi_range(0, random_popup_container.size.y - option.size.y)
		
		var popup_rect = Rect2(Vector2(random_x, random_y), option.size)
		
		intersects = false
		for child: Control in random_popup_container.get_children():
			if child.get_rect().intersects(popup_rect):
				#print(popup_rect, " intersects with ", child.get_rect())
				intersects = true
				break
		
		iteration_max -= 1
		if iteration_max <= 0:
			print("MAX ITERATIONS REACHED")
			break
	
	#print("placed at ", random_x, ", ", random_y)
	random_popup_container.add_child(option)
	option.position = Vector2(random_x, random_y)
	option.modulate = Color(1,1,1,0)
	var fade_in_tween = get_tree().create_tween().tween_property(option, "modulate", Color.WHITE, 0.5)
	await fade_in_tween.finished
		
	await get_tree().create_timer(randf_range(2.0, 6.0)).timeout
	
	if not is_instance_valid(option):
		return
	
	var fade_out_tween = get_tree().create_tween().tween_property(option, "modulate", Color(1,1,1,0), 0.5)
	if not fade_out_tween:
		return
	
	await fade_out_tween.finished
	
	if is_instance_valid(option):
		option.queue_free()
		#print(dialogue_options_queued)
		dialogue_options_queued.push_back(option_index)

# empty dictionary for nothing selected (ignored opponent)
func submit_dialogue(reply: Dictionary):
	respond_time_left_bar.value = 0
	
	if reply.is_empty():
		very_bad_rating()
		var ignored_responses = dialogue["ignored_responses"]
		var ignored_response = ignored_responses[randi_range(0, len(ignored_responses)-1)]
		npc_dialogue_box.show_message(ignored_response)
	else:
		var rating = reply["rating"]
		if rating == "very good":
			very_good_rating()
		elif rating == "good":
			good_rating()
		elif rating == "bad":
			bad_rating()
		elif rating == "very bad":
			very_bad_rating()
		else:
			meh_rating()
			
		var response = reply["response"]
		npc_dialogue_box.show_message(response)
		
	for child in random_popup_container.get_children():
		child.queue_free()
		
	in_dialogue_mode = false
	
	rhythm.min_speed += rhythm.game_screen.level.min_speed_gain
	rhythm.max_speed += rhythm.game_screen.level.max_speed_gain
	rhythm.adjust_speed(0)
	
	rhythm.start_rhythm_mode()

func very_good_rating():
	rating_anim_rect.texture = good_rating_texture
	rhythm.adjust_speed(-100)
	rating_anim(Vector2.UP)

func good_rating():
	rating_anim_rect.texture = good_rating_texture
	rhythm.adjust_speed(-50)
	rating_anim(Vector2.UP)
	
func meh_rating():
	rhythm.adjust_speed(0)
	rating_anim_rect.texture = meh_rating_texture
	rating_anim(Vector2.ZERO)
	
func bad_rating():
	rhythm.adjust_speed(50)
	rating_anim_rect.texture = bad_rating_texture
	rating_anim(Vector2.DOWN)
	
func very_bad_rating():
	rhythm.adjust_speed(100)
	rating_anim_rect.texture = bad_rating_texture
	rating_anim(Vector2.DOWN)
	
func rating_anim(dir: Vector2):
	var base_position = rating_anim_rect.position
	rating_anim_rect.modulate = Color.WHITE
	
	get_tree().create_tween().tween_property(rating_anim_rect, "modulate", Color(1,1,1,0), 1.0)
	await get_tree().create_tween().tween_property(rating_anim_rect, "position", base_position + dir*50, 1.0).finished
	
	if is_instance_valid(rating_anim_rect):
		rating_anim_rect.modulate = Color(1,1,1,0)
		rating_anim_rect.position = base_position

	
