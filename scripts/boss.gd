class_name boss extends CharacterBody2D

enum BossState { IDLE, RUN, JUMP, ATTACK, STAY, HURT, DEATH }

const SPEED = 50.0
const JUMP_VELOCITY = -100.0
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon = get_node("Weapon")
@onready var player = get_node("/root/Main/Player")
@onready var timer: Timer = $Weapon/Timer
@onready var win_label: Label = get_node("/root/Main/labels/winLabel")
@onready var timer_2: Timer = $Weapon/Timer2
@onready var death_timer: Timer = $DeathTimer
@onready var ui = get_node("/root/Main/UI")
@onready var death: AudioStreamPlayer2D = $Death
@onready var hurt: AudioStreamPlayer2D = $Hurt
@onready var strike: AudioStreamPlayer2D = $Strike
var is_battle_started = false
var health = 3
var current_state = BossState.IDLE
var can_attack = false
var invincible = false
var player_in_zone = false
var is_dead = false

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	
	if ray_cast_left.is_colliding():
		is_battle_started = true

	if not is_battle_started:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_dead:
		return
	
	if not is_battle_started:
		return
	if player.position.x < position.x:
		$AnimatedSprite2D.flip_h = true
	if player.position.x > position.x:
		$AnimatedSprite2D.flip_h = false
		
	match current_state:
		BossState.IDLE:
			sprite.play("idle")
			if player and abs(player.position.x - position.x) < 200:
				current_state = BossState.RUN
				
		BossState.RUN:
			sprite.play("run")
			var direction = sign(player.position.x - position.x)
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
			var distance = abs(player.position.x - position.x)
			if distance < 30:
				current_state = BossState.ATTACK
			elif distance < 200:
				current_state = BossState.RUN
			elif is_on_floor():
				current_state = BossState.JUMP

		BossState.ATTACK:
			strike.play()
			sprite.play("attack")
			velocity.x = 0
			if abs(player.position.x - position.x) > 200:
				current_state = BossState.RUN
			elif sprite.frame > 10 and sprite.animation_looped and sprite.animation == "attack":
				attack()
				current_state = BossState.STAY
				
		BossState.JUMP:
			velocity.y = JUMP_VELOCITY
		BossState.STAY:
			sprite.play("idle")
			current_state = BossState.IDLE
		BossState.HURT:
			sprite.play("hurt")
			velocity = Vector2.ZERO
			if sprite.frame > 13 and sprite.animation_finished and sprite.animation == "hurt":
				current_state = BossState.IDLE
		BossState.DEATH:
			velocity = Vector2.ZERO
			death.play()
			ui.save_to_file()
			sprite.play("death")
			if sprite.frame > 21 and sprite.animation_finished and sprite.animation == "death":
				win_label.visible = true
				death_timer.start()
				is_dead = true
				visible = false
	position += velocity * delta

	move_and_slide()
	
func attack():
	
	if player.get_death():
		return
	
	if player_in_zone:
		player.set_death()
		Engine.time_scale = 0.5
		timer_2.start()
	pass
	


func _on_weapon_body_entered(body: Node2D) -> void:
	player_in_zone = true
	if player.get_is_dashing() and not invincible:
		health -= 1
		if health <= 0:
			current_state = BossState.DEATH
		else:
			hurt.play()
			current_state = BossState.HURT
			invincible = true
			timer.start()
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	invincible = false
	current_state = BossState.IDLE
	pass # Replace with function body.


func _on_weapon_body_exited(body: Node2D) -> void:
	player_in_zone = false
	if player.get_is_dashing() and not invincible:
		health -= 1
		if health <= 0:
			current_state = BossState.DEATH
		else: 
			hurt.play()
			current_state = BossState.HURT
			invincible = true
			timer.start()
	pass # Replace with function body.


func _on_timer_2_timeout() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1.0
	pass # Replace with function body.


func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene()
	pass # Replace with function body.
