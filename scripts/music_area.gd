extends Area2D

@onready var music: AudioStreamPlayer2D = $Music
@onready var track: AudioStream = preload("res://assets/BoxCat Games - CPU Talk.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	music.stop()
	music.stream = track
	music.stream.loop = true
	music.play()
	pass # Replace with function body.
