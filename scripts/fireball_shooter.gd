extends CharacterBody2D

@export var fireball_scene: PackedScene = preload("res://scenes/fireball.tscn")
@export var fire_rate: float = 1.5
@export var facing: Vector2 = Vector2.LEFT # enemy shoots left by default

@export var hp: int = 3
@export var soul_reward: int = 15
var is_dead: bool = false
var invulnerable: bool = false

func _ready() -> void:
	add_to_group("enemy")
	$Timer.wait_time = fire_rate
	$Timer.timeout.connect(_shoot_fireball)

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		facing = (player.global_position - global_position).normalized()

		# Flip sprite visually
		$AnimatedSprite2D.flip_h = facing.x < 0

func _shoot_fireball() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Only shoot if player is within 1000 pixels
	if global_position.distance_to(player.global_position) > 200:
		return

	var fb = fireball_scene.instantiate()
	fb.shooter = self
	fb.position = $ShootPoint.global_position
	fb.direction = facing

	if fb.has_node("AnimatedSprite2D"):
		fb.get_node("AnimatedSprite2D").flip_h = facing.x < 0

	get_tree().current_scene.add_child(fb)


func take_damage() -> void:
	if is_dead or invulnerable:
		return
	
	hp -= 1
	if hp <= 0:
		die()
	else:
		# Flash red
		$AnimatedSprite2D.modulate = Color.RED
		invulnerable = true
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.modulate = Color.WHITE
		invulnerable = false

func die() -> void:
	is_dead = true
	Game_config.add_soul(soul_reward)
	# Play death animation if exists, otherwise just fade/pop or queue_free
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Simple death effect: fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_is_dashing():
			take_damage()
		else:
			body.take_damage()
