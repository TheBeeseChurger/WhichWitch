class_name Note
extends RefCounted

enum NoteType {
	TAP = 0,
	HOLD = 1,
	SLIDE = 2,
	SPECIAL = 3,
}

var start_time: float
var duration: float
var track: int
var type: int

func _init(_start_time: float = 0.0, _duration: float = 0.0, _track: int = 0, _type: int = NoteType.TAP):
	start_time = _start_time
	duration = _duration
	track = _track
	type = _type
