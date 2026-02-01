extends CharacterBody2D

const SPEED = 100.0
const CHASE_SPEED = 140.0
const JUMP_VELOCITY = -400.0
const MAX_HP = 50
const SOUL_REWARD = 100

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null
var hp = MAX_HP
var is_dead = false
var facing_right = true
var attack_cooldown = false
var can_shoot = true

enum State {IDLE, PATROL, CHASE, ATTACK, SHOOT, HIT, DEATH}
var current_state = State.IDLE

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var shoot_timer = $ShootTimer
@export var fireball_scene: PackedScene = preload("res://scenes/fireball.tscn")

func _ready():
	add_to_group("enemy")
	animated_sprite.play("idle")
	shoot_timer.wait_time = 3.0
	shoot_timer.start()

func _physics_process(delta):
	if is_dead:
		velocity.y += gravity * delta
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		State.IDLE:
			velocity.x = 0
			animated_sprite.play("idle")
			if player:
				current_state = State.CHASE

		State.CHASE:
			if player:
				var direction = (player.global_position - global_position).normalized()
				velocity.x = direction.x * CHASE_SPEED
				if animated_sprite.animation != "run":
					animated_sprite.play("run")
				
				# Flip sprite
				if velocity.x > 0:
					animated_sprite.flip_h = false
					facing_right = true
				elif velocity.x < 0:
					animated_sprite.flip_h = true
					facing_right = false
				
				if overlaps_attack_area() and not attack_cooldown:
					perform_melee_attack()
			else:
				current_state = State.IDLE

		State.ATTACK:
			velocity.x = 0
			# Melee wait

		State.SHOOT:
			velocity.x = 0
			# Shoot wait

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player = null
		current_state = State.IDLE

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and not attack_cooldown and current_state != State.DEATH:
		perform_melee_attack()

func perform_melee_attack():
	if is_dead: return
	current_state = State.ATTACK
	animated_sprite.play("attack")
	attack_cooldown = true
	
	await animated_sprite.animation_finished
	# Check hit at end of animation
	if player and player.has_method("take_damage") and overlaps_attack_area():
		player.take_damage()
	
	current_state = State.CHASE
	await get_tree().create_timer(1.0).timeout
	attack_cooldown = false

func overlaps_attack_area() -> bool:
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false

func _on_shoot_timer_timeout():
	if is_dead or not player: return
	
	if current_state == State.CHASE:
		perform_ranged_attack()

func perform_ranged_attack():
	current_state = State.SHOOT
	animated_sprite.play("attack")
	
	await get_tree().create_timer(0.3).timeout
	if is_dead: return
	
	var fb = fireball_scene.instantiate()
	fb.global_position = global_position + Vector2(20 if facing_right else -20, -10)
	var dir = Vector2.RIGHT if facing_right else Vector2.LEFT
	fb.direction = dir
	fb.shooter = self
	get_parent().add_child(fb)
	
	await animated_sprite.animation_finished
	current_state = State.CHASE

func take_damage(amount = 1):
	hp -= amount
	if hp <= 0:
		die()
	else:
		animated_sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		animated_sprite.modulate = Color.WHITE

func die():
	is_dead = true
	current_state = State.DEATH
	animated_sprite.play("death")
	Game_config.add_soul(SOUL_REWARD)
	await animated_sprite.animation_finished
	queue_free()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("player"):
		# Using has_method check to be safe, though we know player has it
		if body.has_method("get_is_dashing") and body.get_is_dashing():
			take_damage(1)
		else:
			body.take_damage()
