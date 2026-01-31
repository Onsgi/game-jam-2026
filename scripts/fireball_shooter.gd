extends CharacterBody2D

@export var fireball_scene: PackedScene = preload("res://scenes/fireball.tscn")
@export var fire_rate: float = 1.5
@export var facing: Vector2 = Vector2.LEFT   # enemy shoots left by default

func _ready() -> void:
	$Timer.wait_time = fire_rate
	$Timer.timeout.connect(_shoot_fireball)

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		facing = (player.global_position - global_position).normalized()

		# Flip sprite visually
		$AnimatedSprite2D.flip_h = facing.x < 0

func _shoot_fireball() -> void:
	var fb = fireball_scene.instantiate()

	# Spawn at the shoot point
	fb.position = $ShootPoint.global_position

	# Set direction
	fb.direction = facing

	# Flip fireball animation if needed
	if fb.has_node("AnimatedSprite2D"):
		fb.get_node("AnimatedSprite2D").flip_h = facing.x < 0

	get_tree().current_scene.add_child(fb)
