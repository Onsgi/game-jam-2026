extends Area2D

@onready var label := $Label
var full_text := "Hello traveler. \nUse WASD to Move.\n and Z to dash"
var speed := 0.04
var index := 0

func _ready():
	label.text = ""
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		show_text()

func show_text():
	index = 0
	label.text = ""
	while index < full_text.length():
		index += 1
		label.text = full_text.substr(0, index)
		await get_tree().create_timer(speed).timeout
