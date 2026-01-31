extends Area2D
class_name Enemy

@export var hp = 3
@export var soul_reward = 11

var is_dead = false
var invulnerable = false
@onready var animated_sprite = $AnimatedSprite2D

func take_damage(amount):
	if is_dead or invulnerable:
		return
		
	hp -= amount
	if hp <= 0:
		die()
	else:
		hit_feedback()

func die():
	is_dead = true
	Game_config.add_soul(soul_reward)
	if animated_sprite:
		animated_sprite.play("death")
	# queue_free logic usually handled by animation finished signal in subclass

func hit_feedback():
	if animated_sprite:
		animated_sprite.modulate = Color.RED
		invulnerable = true
		await get_tree().create_timer(0.2).timeout
		animated_sprite.modulate = Color.WHITE
		invulnerable = false
