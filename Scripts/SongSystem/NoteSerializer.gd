# res://scripts/NoteSerializer.gd
extends Node
class_name NoteSerializer

const FLOAT_SIZE := 4
const INT_SIZE := 4
const BYTE_SIZE := 1

# Each BPM range is 4 floats -> 16 bytes
const BPM_RANGE_SIZE := FLOAT_SIZE * 4

# Each note is 2 floats + 2 bytes -> 10 bytes
const NOTE_SIZE := FLOAT_SIZE + FLOAT_SIZE + BYTE_SIZE + BYTE_SIZE

# --- BPM RANGE HANDLING ---

static func _serialize_bpm_ranges(bpm_ranges: Array) -> PackedByteArray:
	var buffer := PackedByteArray()
	buffer.resize(INT_SIZE + bpm_ranges.size() * BPM_RANGE_SIZE)

	# Write count at the start
	buffer.encode_u32(0, bpm_ranges.size())

	var byte_index := INT_SIZE
	for range in bpm_ranges:
		buffer.encode_float(byte_index, range.start_time)
		byte_index += FLOAT_SIZE

		buffer.encode_float(byte_index, range.start_bpm)
		byte_index += FLOAT_SIZE

		buffer.encode_float(byte_index, range.min_bpm)
		byte_index += FLOAT_SIZE

		buffer.encode_float(byte_index, range.max_bpm)
		byte_index += FLOAT_SIZE

	return buffer

static func _deserialize_bpm_ranges(buffer: PackedByteArray, offset: int) -> Dictionary:
	var bpm_count = buffer.decode_u32(offset)
	offset += INT_SIZE

	var bpm_ranges: Array = []
	for i in bpm_count:
		var start_time = buffer.decode_float(offset)
		offset += FLOAT_SIZE

		var start_bpm = buffer.decode_float(offset)
		offset += FLOAT_SIZE

		var min_bpm = buffer.decode_float(offset)
		offset += FLOAT_SIZE

		var max_bpm = buffer.decode_float(offset)
		offset += FLOAT_SIZE

		bpm_ranges.append(BPMRange.new(start_time, start_bpm, min_bpm, max_bpm))

	return {
		"ranges": bpm_ranges,
		"offset": offset # where the note data starts
	}

# --- NOTE HANDLING ---

static func _serialize_notes(notes: Array) -> PackedByteArray:
	var buffer := PackedByteArray()
	buffer.resize(INT_SIZE + notes.size() * NOTE_SIZE)

	# Write count
	buffer.encode_u32(0, notes.size())

	var byte_index := INT_SIZE
	for note in notes:
		buffer.encode_float(byte_index, note.start_time)
		byte_index += FLOAT_SIZE

		buffer.encode_float(byte_index, note.duration)
		byte_index += FLOAT_SIZE

		buffer[byte_index] = note.track
		byte_index += BYTE_SIZE

		buffer[byte_index] = note.type
		byte_index += BYTE_SIZE

	return buffer

static func _deserialize_notes(buffer: PackedByteArray, offset: int) -> Array:
	var note_count = buffer.decode_u32(offset)
	offset += INT_SIZE

	var notes: Array = []
	for i in note_count:
		var start_time = buffer.decode_float(offset)
		offset += FLOAT_SIZE

		var duration = buffer.decode_float(offset)
		offset += FLOAT_SIZE

		var track = buffer[offset]
		offset += BYTE_SIZE

		var type = buffer[offset]
		offset += BYTE_SIZE

		notes.append(Note.new(start_time, duration, track, type))

	return notes

# --- PUBLIC FUNCTIONS ---

static func save_to_file(path: String, bpm_ranges: Array, notes: Array) -> void:
	# Serialize BPM ranges and notes separately
	var bpm_buffer = _serialize_bpm_ranges(bpm_ranges)
	var note_buffer = _serialize_notes(notes)

	# Combine into one final buffer
	var final_buffer := PackedByteArray()
	final_buffer.append_array(bpm_buffer)
	final_buffer.append_array(note_buffer)

	# Write to file
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_buffer(final_buffer)
		file.close()

static func load_from_file(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {
			"bpm_ranges": [],
			"notes": []
		}

	var buffer = file.get_buffer(file.get_length())
	file.close()

	# First, parse BPM ranges
	var bpm_data = _deserialize_bpm_ranges(buffer, 0)

	# Next, parse notes starting from where BPM parsing ended
	var notes = _deserialize_notes(buffer, bpm_data.offset)

	return {
		"bpm_ranges": bpm_data.ranges,
		"notes": notes
	}
