class_name Player extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -300.0
var dash_speed = 200
var dash_time = 0.2
var dash_direction = Vector2.ZERO
var is_dashing = false
var dash_timer = 1.0
var is_dead = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash: AudioStreamPlayer2D = $Dash
@onready var jump: AudioStreamPlayer2D = $Jump
@onready var death: AudioStreamPlayer2D = $Death


func _ready():
	if Game_config.has_checkpoint:
		global_position = Game_config.last_checkpoint_position

func _physics_process(delta: float) -> void:
	if is_dead:
		animated_sprite_2d.play("death")
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump.play()
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
		
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	if Input.is_action_just_pressed("dash"):
		dash.play()
		is_dashing = true
		if direction != 0:
			dash_direction = direction
		else:
			dash_direction = -1 if animated_sprite_2d.flip_h else 1
		dash_timer = dash_time
		
	if is_dashing:
		animated_sprite_2d.play("dash")
		velocity.x = dash_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("jump")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func set_death():
	death.play()
	is_dead = true
	
func get_death():
	return is_dead

func take_damage():
	Game_config.take_damage()
	if Game_config.lives <= 0:
		set_death()
		Engine.time_scale = 0.5
		# We might want to trigger the reload timer here or key off an animation
		# For now, let's trust Game_config's signal or handle it elsewhere if needed.
		# But since original code did reload in slime, we might need a manager or timer.
		# For simply matching request:
		get_tree().create_timer(1.0).timeout.connect(func():
			Engine.time_scale = 1.0
			Game_config.reset_game()
			get_tree().reload_current_scene()
		)
	else:
		# Visual feedback for damage
		animated_sprite_2d.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		animated_sprite_2d.modulate = Color.WHITE

func get_is_dashing():
	return is_dashing
