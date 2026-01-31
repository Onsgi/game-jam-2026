extends CanvasLayer

@onready var scoreLabel: Label = $Hud/VBoxContainer/Score
@onready var high_score: Label = $Hud/VBoxContainer/HighScore

func _ready() -> void:
	Game_config.soul_updated.connect(update_soul_label)
	Game_config.lives_updated.connect(func(_lives): pass ) # Can add life UI update here later
	
	# Initial update
	update_soul_label(Game_config.soul)
	# Highscore is handled in Game_config but we can display it if needed, or remove.
	# For now, let's just make sure "high_score" label is updated or hidden if irrelevant.
	high_score.text = "" # Or remove it if souls don't really have a highscore in the same way?
	# Assuming "high score" was for coins. Let's hide it for now or just ignore.

func update_soul_label(new_soul):
	scoreLabel.text = "Souls: " + str(new_soul)

# Called by coin.gd
func add_coin_to_score():
	# Coins now give 1 soul? Or maybe more? Let's say 5 for now, or 1.
	Game_config.add_soul(5)
