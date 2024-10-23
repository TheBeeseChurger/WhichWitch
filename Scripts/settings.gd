extends Node
enum DifficultyType {Easy = 0, Normal = 1, Hard = 2}

var difficulty : DifficultyType = DifficultyType.Normal
var difficulty_mult: float = .75

func set_difficulty(newDifficulty: DifficultyType) -> void:
	difficulty = newDifficulty
	update_difficulty_mult()
	print(difficulty)

func get_difficulty() -> int:
	return int(difficulty)
	
func bump_difficulty(bumpAmount: int = 1) -> int:
	var newVal: int = (int(difficulty) + bumpAmount) % DifficultyType.values().size()
	difficulty = DifficultyType.values()[newVal]
	update_difficulty_mult()
	
	return newVal

func get_difficulty_string() -> String:
	match(difficulty):
		DifficultyType.Easy:
			return "Easy"
		DifficultyType.Hard:
			return "Hard"
		_:
			difficulty = DifficultyType.Normal
			return "Normal"

func get_difficulty_mult() -> float:
	return difficulty_mult

func update_difficulty_mult() -> float:
	match(difficulty):
		DifficultyType.Easy:
			return 0.5
		DifficultyType.Hard:
			return 1.25
		_:
			difficulty = DifficultyType.Normal
			return 0.75
