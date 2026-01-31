extends Node

signal score_updated(new_score)
signal lives_updated(new_lives)
signal coins_updated(new_coins)
signal soul_updated(new_soul)

var paused = false
var score = 0
var lives = 3
var coins = 0
var highscore = 0
var last_checkpoint_position = Vector2.ZERO
var has_checkpoint = false
var last_checkpoint_scene = ""

var soul = 0
const MAX_SOUL = 100
const HEAL_COST = 33
const SOUL_GAIN = 11
const MAX_LIVES = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highscore = load_from_file()
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func respawn_player():
	reset_game()
	if has_checkpoint and last_checkpoint_scene != "":
		get_tree().change_scene_to_file(last_checkpoint_scene)
	else:
		get_tree().reload_current_scene()


func heal():
	if lives < MAX_LIVES:
		lives += 1
		lives_updated.emit(lives)
		
func add_soul(amount):
	soul = min(soul + amount, MAX_SOUL)
	soul_updated.emit(soul)
	print("Soul: ", soul)

func spend_soul(amount) -> bool:
	if soul >= amount:
		soul -= amount
		soul_updated.emit(soul)
		return true
	return false

func take_damage():
	lives -= 1
	lives_updated.emit(lives)
	print("lives: ", lives)
	if lives == 0:
		if score > highscore:
			save_to_file(score)

func add_score(amount):
	score += amount
	score_updated.emit(score)

func reset_game():
	score = 0
	lives = 3
	score_updated.emit(score)
	lives_updated.emit(lives)
	coins_updated.emit(coins)

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pause_event()

func pause_event():
	var canvas_layer = get_tree().current_scene.get_node("UI")
	var _pause_menu = canvas_layer.get_node("Pause")
	print("hello")
		
	if get_tree().paused:
		get_tree().paused = false
		_pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		print("Game Unpaused")
		
	else:
		get_tree().paused = true
		_pause_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#print("Game Paused")

func load_from_file():
	var file = FileAccess.open("user://highscore.txt", FileAccess.READ)
	if file:
		var content = file.get_line().to_int()
		return content
	return 0

func save_to_file(content):
	var file = FileAccess.open("user://highscore.txt", FileAccess.WRITE)
	file.store_line(str(content))

func save_master_vol(content):
	var file = FileAccess.open("user://master_vol.txt", FileAccess.WRITE)
	file.store_line(str(content))

func load_master_vol():
	var file = FileAccess.open("user://master_vol.txt", FileAccess.READ)
	if file:
		var content = file.get_line().to_float()
		#print(content)
		return content
	return 0.5

func save_sfx_vol(content):
	var file = FileAccess.open("user://sfx_vol.txt", FileAccess.WRITE)
	file.store_line(str(content))

func load_sfx_vol():
	var file = FileAccess.open("user://sfx_vol.txt", FileAccess.READ)
	if file:
		var content = file.get_line().to_float()
		return content
	return 0.5

func save_music_vol(content):
	var file = FileAccess.open("user://music_vol.txt", FileAccess.WRITE)
	file.store_line(str(content))

func load_music_vol():
	var file = FileAccess.open("user://music_vol.txt", FileAccess.READ)
	if file:
		var content = file.get_line().to_float()
		return content
	return 0.5
