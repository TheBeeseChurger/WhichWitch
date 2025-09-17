# res://scripts/BPMRange.gd
class_name BPMRange
extends RefCounted

var start_time: float
var start_bpm: float
var min_bpm: float
var max_bpm: float

func _init(_start_time: float = 0.0, _start_bpm: float = 120.0, _min_bpm: float = 120.0, _max_bpm: float = 120.0):
	start_time = _start_time
	start_bpm = _start_bpm
	min_bpm = _min_bpm
	max_bpm = _max_bpm
