class_name Player extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -300.0
var dash_speed = 300
var dash_time = 0.2
var dash_direction = Vector2.ZERO
var is_dashing = false
var dash_timer = 1.0
var is_dead = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash: AudioStreamPlayer2D = $Dash
@onready var jump: AudioStreamPlayer2D = $Jump
@onready var death: AudioStreamPlayer2D = $Death


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
	
	if Input.is_action_just_pressed("dash") and direction != 0:
		dash.play()
		is_dashing = true
		dash_direction = direction
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

func get_is_dashing():
	return is_dashing
