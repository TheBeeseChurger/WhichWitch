extends Node
enum DifficultyType {Easy = 0, Normal = 1, Hard = 2}

static var difficulty : DifficultyType = DifficultyType.Normal

var difficulty_mult : Dictionary = {
	"Easy" : 0.75,
	"Normal" : 1,
	"Hard" : 1.5
}
static func current_difficulty_mult():
	return Settings.difficulty_mult[get_difficulty_string()]

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

static func get_difficulty_string() -> String:
	match(difficulty):
		DifficultyType.Easy:
			return "Easy"
		DifficultyType.Hard:
			return "Hard"
		_:
			difficulty = DifficultyType.Normal
			return "Normal"

func update_difficulty_mult() -> float:
	match(difficulty):
		DifficultyType.Easy:
			return 0.5
		DifficultyType.Hard:
			return 1.25
		_:
			difficulty = DifficultyType.Normal
			return 0.75
