extends CanvasLayer

@onready var scoreLabel: Label = $Score
@onready var high_score: Label = $HighScore

var score = 0

func _ready() -> void:
	var old_score = load_from_file()
	set_high_score(old_score)

# Called when the node enters the scene tree for the first time.
func add_coin_to_score():
	score += 1
	scoreLabel.text = "Coins: " + str(score) + "/24"
	
func set_high_score(new_score: int):
	high_score.text = "\nHigh score: " + str(new_score)

func save_to_file():
	if score > load_from_file():
		var file = FileAccess.open("user://highscore.txt", FileAccess.WRITE)
		file.store_string(str(score))

func load_from_file():
	var file = FileAccess.open("user://highscore.txt", FileAccess.READ)
	if file == null:
		return 0
	var content = int(file.get_as_text())
	return content
