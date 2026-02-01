extends CharacterBody2D

const SPEED = 80.0
const CHASE_SPEED = 120.0
const JUMP_VELOCITY = -300.0

# Stats
var hp = 3
var max_hp = 3
var soul_reward = 20
var is_dead = false
var invulnerable = false

# AI States
enum State {IDLE, PATROL, CHASE, ATTACK}
var current_state = State.IDLE
var player = null
var direction = 1 # 1 for right, -1 for left

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea

func _ready():
	add_to_group("enemy")
	print("Cultist Ready")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	match current_state:
		State.IDLE:
			attack_area.get_node("CollisionShape2D").disabled = true
			velocity.x = 0
			animated_sprite.play("idle")
			
			if randf() < 0.01:
				current_state = State.PATROL
				direction = 1 if randf() > 0.5 else -1
				update_facing()
			
		State.PATROL:
			attack_area.get_node("CollisionShape2D").disabled = true
			velocity.x = direction * SPEED
			animated_sprite.play("run")
			
			update_facing()
				
			if is_on_wall() or not is_on_floor():
				direction *= -1
				update_facing()
			
			if randf() < 0.01:
				current_state = State.IDLE
			
		State.CHASE:
			attack_area.get_node("CollisionShape2D").disabled = true
			if player:
				var dir_to_player = (player.global_position - global_position).normalized().x
				velocity.x = dir_to_player * CHASE_SPEED
				direction = 1 if dir_to_player > 0 else -1
				update_facing()
				
				animated_sprite.play("run")
				
				if global_position.distance_to(player.global_position) < 40:
					current_state = State.ATTACK

		State.ATTACK:
			velocity.x = 0
			animated_sprite.play("attack")
			attack_area.get_node("CollisionShape2D").disabled = false

	move_and_slide()

func update_facing():
	if direction > 0:
		animated_sprite.flip_h = false
		attack_area.position.x = 10
	else:
		animated_sprite.flip_h = true
		attack_area.position.x = -10

func _on_animated_sprite_2d_animation_finished():
	if current_state == State.ATTACK:
		attack_area.get_node("CollisionShape2D").disabled = true
		current_state = State.CHASE
	elif is_dead:
		queue_free()

func take_damage(amount):
	if is_dead or invulnerable:
		return
		
	hp -= amount
	if hp <= 0:
		die()
	else:
		animated_sprite.modulate = Color.RED
		invulnerable = true
		await get_tree().create_timer(0.2).timeout
		animated_sprite.modulate = Color.WHITE
		invulnerable = false

func die():
	is_dead = true
	Game_config.add_soul(soul_reward)
	animated_sprite.play("death")
	$CollisionShape2D.set_deferred("disabled", true)

func _on_detection_area_body_entered(body):
	if body is Player:
		player = body
		current_state = State.CHASE

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		current_state = State.IDLE

func _on_attack_area_body_entered(body):
	if body is Player:
		if not body.get_is_dashing():
			body.take_damage() # Player handles its own HP decrement

func _on_hurtbox_body_entered(body):
	if body is Player:
		if body.get_is_dashing():
			take_damage(1)
		else:
			body.take_damage()
