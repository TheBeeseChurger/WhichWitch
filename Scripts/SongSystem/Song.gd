# res://scripts/Song.gd
class_name Song
extends Resource

# --- Song Metadata ---
@export var song_name: String = ""             # Display name of the song
@export var artist: String = ""                # Song artist
@export var audio_stream: AudioStream = null   # The audio used for the song
@export var first_beat_time: float = 0.0       # Time in seconds where first beat occurs

# --- Difficulties ---
@export var difficulties: Array[DifficultyData] = []  # List of difficulties

# --- Methods ---

# Returns the path to the notes file for a given difficulty name
func get_notes_file_for_difficulty(diff_name: String) -> String:
	for diff in difficulties:
		if diff.difficulty_name == diff_name:
			return diff.notes_file_path
	return ""

# Load notes for a given difficulty using NoteSerializer
func load_notes(diff_name: String) -> Dictionary:
	var notes_path = get_notes_file_for_difficulty(diff_name)
	if notes_path.is_empty():
		push_error("Difficulty '%s' not found or no path set." % diff_name)
		return {"bpm_ranges": [], "notes": []}

	return NoteSerializer.load_from_file(notes_path)

# Save notes for a given difficulty
func save_notes(diff_name: String, bpm_ranges: Array, notes: Array) -> void:
	var notes_path = get_notes_file_for_difficulty(diff_name)
	if notes_path.is_empty():
		push_error("Difficulty '%s' not found or no path set." % diff_name)
		return

	NoteSerializer.save_to_file(notes_path, bpm_ranges, notes)
