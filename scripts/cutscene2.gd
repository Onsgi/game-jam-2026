extends Area2D

@onready var cutscene_ui := $"CutsceneUI"
@onready var enemy_image := cutscene_ui.get_node("TextureRect")
@onready var protagonist_image := cutscene_ui.get_node("TextureRect2")
@onready var text_label := cutscene_ui.get_node("Label")
@onready var fade_panel := cutscene_ui.get_node("ColorRect")
@onready var music_player:= get_node("/root/Node2D/MusicPlayer")

var protagonist_text := "You won't stop me..."
var enemy_text := "We shall see...\n We shall see"

var text_speed := 0.04
var cutscene_played := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player") and not cutscene_played:
		cutscene_played = true
		start_cutscene(body)

func start_cutscene(player):
	player.set_process(false)
	player.set_physics_process(false)
	#music_player.stop()
	#music_player.stream = preload("res://Assets/background/level3.mp3")
	#music_player.volume_db = 0.0
	#music_player.play()

	cutscene_ui.visible = true
	text_label.text = ""

	# Reset visuals
	protagonist_image.modulate.a = 0.0
	enemy_image.modulate.a = 0.0
	fade_panel.modulate.a = 0.0

	# --- PHASE 1: Fade in protagonist ---
	await fade_in(protagonist_image, 1.5)
	await type_text(protagonist_text)
	await get_tree().create_timer(3).timeout
	text_label.text = ""

	# --- PHASE 2: Fade to black ---
	await fade_in(fade_panel, 1.0)

	# --- PHASE 3: Switch images while screen is black ---
	protagonist_image.modulate.a = 0.0
	enemy_image.modulate.a = 1.0

	# --- PHASE 4: Fade back from black ---
	await fade_out(fade_panel, 1.0)

	# --- PHASE 5: Enemy text ---
	text_label.text = ""
	await type_text(enemy_text)

	await get_tree().create_timer(1.5).timeout
	end_cutscene(player)

func fade_in(node, duration):
	var t = create_tween()
	t.tween_property(node, "modulate:a", 1.0, duration)
	await t.finished

func fade_out(node, duration):
	var t = create_tween()
	t.tween_property(node, "modulate:a", 0.0, duration)
	await t.finished

func type_text(text):
	for i in text.length():
		text_label.text = text.substr(0, i + 1)
		await get_tree().create_timer(text_speed).timeout

func end_cutscene(player):
	var t = create_tween()
	t.tween_property(text_label, "modulate:a", 0.0, 1.0)
	t.tween_property(enemy_image, "modulate:a", 0.0, 1.0)
	await t.finished

	cutscene_ui.visible = false
	player.set_process(true)
	player.set_physics_process(true)
