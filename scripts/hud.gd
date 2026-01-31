extends Control

@onready var score_label = $VBoxContainer/Score
@onready var health = $VBoxContainer/Health
@onready var coin_label = $VBoxContainer/Coins

func _ready():
	Game_config.score_updated.connect(update_score)
	Game_config.lives_updated.connect(update_lives)
	Game_config.coins_updated.connect(update_coins)
	update_coins(Game_config.coins)
	update_score(Game_config.score)
	update_lives(Game_config.lives)


func update_score(new_score):
	score_label.text = "SCORE: %d" % new_score
	
func update_coins(new_coins):
	if new_coins == 0:
		coin_label.hide()
	else:
		coin_label.show()
		coin_label.text = "COINS NOT COLLECTED: %d" % new_coins

func update_lives(new_lives):
	#print("xd")
	for child in health.get_children():
		child.queue_free()
	for i in range(new_lives):
		var life_icon = TextureRect.new()
		var img = load("res://Assets/pixel-heart-2779422_1280.webp")
		life_icon.texture = img
		health.add_child(life_icon)
