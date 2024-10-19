class_name Level
extends Resource

static var current_level: Level

@export var starting_speed: float = 300
@export var min_speed: float = 200
@export var min_speed_gain: float = 25 # amount min_speed increases by at the end of each round
@export var max_speed: float = 600
@export var max_speed_gain: float = 0 # amount max_speed increases by at the end of each round

# level that comes after this level, if any.
@export var next_level: Level

@export var dialogue_name: String

@export var dynamic_music: DynamicMusic

@export var background_texture: Texture2D

@export var note_textures: Array[Texture2D]

@export var note_hit_textures: Array[Texture2D]
