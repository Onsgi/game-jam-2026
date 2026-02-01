extends Area2D

@onready var cutscene_ui := $"CutsceneUI"
@onready var enemy_image := cutscene_ui.get_node("TextureRect")
@onready var text_label := cutscene_ui.get_node("Label")

var cutscene_text := "Hello...                                     \n Prepare to die"
var text_speed := 0.04
var cutscene_duration := 5.0
var cutscene_played := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player") and not cutscene_played:
		cutscene_played = true
		start_cutscene(body)
		
func start_cutscene(player):
	# 1. Disable player movement
	player.set_process(false)
	player.set_physics_process(false)

	# 2. Show UI
	cutscene_ui.visible = true
	text_label.text = ""
	enemy_image.modulate.a = 0.0

	# 3. Fade in enemy
	var tween = create_tween()
	tween.tween_property(enemy_image, "modulate:a", 1.0, 2.0)
	await tween.finished

	# 4. Typewriter text
	await type_text(cutscene_text)
	
	# 5. Wait X seconds before ending cutscene
	await get_tree().create_timer(cutscene_duration).timeout
	
	end_cutscene(player)
	
func type_text(text):
	for i in text.length():
		text_label.text = text.substr(0, i + 1)
		await get_tree().create_timer(text_speed).timeout

func end_cutscene(player):
	var tween2 = create_tween()
	tween2.tween_property(text_label, "modulate:a", 0.0, 1.0)
	await tween2.finished
	
	var tween = create_tween()
	tween.tween_property(enemy_image, "modulate:a", 0.0, 1.5)
	await tween.finished
	

	
	cutscene_ui.visible = false
	player.set_process(true)
	player.set_physics_process(true)
