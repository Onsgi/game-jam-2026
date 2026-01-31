class_name Player extends CharacterBody2D

@export var fireball_scene: PackedScene = preload("res://scenes/fireball.tscn")
@export var fire_offset: Vector2 = Vector2(5, -10) # where fireball spawns
var facing: Vector2 = Vector2.RIGHT

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
var dash_speed = 200
var dash_time = 0.2
var dash_direction = Vector2.ZERO
var is_dashing = false
var dash_timer = 1.0
var is_dead = false
var max_jumps := 2
var jumps_left := 2
@onready var dash: AudioStreamPlayer2D = $Dash
@onready var jump: AudioStreamPlayer2D = $Jump
@onready var death: AudioStreamPlayer2D = $Death
@export var fire_frames: SpriteFrames = preload("res://frames/fire.tres")
@export var golden_frames: SpriteFrames = preload("res://frames/golden.tres")
@export var jumping_frames: SpriteFrames = preload("res://frames/jumping.tres")
@onready var current_skin: AnimatedSprite2D = $Skin

@export var enable_double_jump := true

var heal_timer = 0.0

func _ready():
	add_to_group("player")
	if Game_config.has_checkpoint and Game_config.last_checkpoint_scene == get_tree().current_scene.scene_file_path:
		global_position = Game_config.last_checkpoint_position
	
	# Restore saved skin
	switch_skin(Game_config.current_skin)

# ... (omitting intermediate code for brevity if not modifying, but here I need to update switch_skin)

func switch_skin(new_skin: String):
	Game_config.current_skin = new_skin
	match new_skin:
		"fire":
			current_skin.sprite_frames = fire_frames
		"golden":
			current_skin.sprite_frames = golden_frames
		"jumping":
			current_skin.sprite_frames = jumping_frames

	current_skin.play("idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		current_skin.play("death")
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump + optional double jump
	if is_on_floor():
		jumps_left = max_jumps

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump.play()
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
		elif enable_double_jump and jumps_left > 0 and Game_config.has_mask("jumping"):
			jump.play()
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1

	var direction := Input.get_axis("move_left", "move_right")
		
	if direction > 0:
		current_skin.flip_h = false
		facing = Vector2.RIGHT
	elif direction < 0:
		current_skin.flip_h = true
		facing = Vector2.LEFT
		
	if Input.is_action_just_pressed("fire") and Game_config.has_mask("fire"):
		shoot_fireball()
	
	if Input.is_action_just_pressed("dash") and Game_config.has_mask("golden"):
		dash.play()
		is_dashing = true
		if direction != 0:
			dash_direction = direction
		else:
			dash_direction = -1 if current_skin.flip_h else 1
		dash_timer = dash_time
		
	if is_dashing:
		current_skin.play("dash")
		velocity.x = dash_direction * dash_speed
		# Disable collision with enemies (Layer 3, Value 4)
		set_collision_mask_value(3, false)
		
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			set_collision_mask_value(3, true)
	else:
		set_collision_mask_value(3, true) # Ensure it's reset
		if is_on_floor():
			if direction == 0:
				current_skin.play("idle")
			else:
				current_skin.play("run")
		else:
			current_skin.play("jump")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Healing Logic
	if Input.is_action_pressed("heal") and is_on_floor() and velocity.x == 0:
		if Game_config.lives < Game_config.MAX_LIVES:
			heal_timer += delta
			if heal_timer > 0.0:
				# Show charging effect (optional, e.g., faint glow)
				current_skin.modulate = Color(0.8, 1, 0.8) # Light green
			
			if heal_timer >= 1.0:
				if Game_config.spend_soul(Game_config.HEAL_COST):
					Game_config.heal()
					# Visual feedback for successful heal
					current_skin.modulate = Color(0, 1, 0) # Full green
					await get_tree().create_timer(0.2).timeout
					heal_timer = 0.0 # Reset for next heal
				else:
					# Not enough soul, maybe sound effect?
					heal_timer = 0.0
					current_skin.modulate = Color(1, 1, 1)
		else:
			heal_timer = 0.0
			current_skin.modulate = Color(1, 1, 1)
	else:
		heal_timer = 0.0
		# Reset modulate unless taking damage (handled in take_damage)
		# We need to be careful not to override damage red flash
		if not is_dead and current_skin.modulate != Color.RED:
			current_skin.modulate = Color(1, 1, 1)


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
			Game_config.respawn_player()
		)
	else:
		# Visual feedback for damage
		current_skin.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		current_skin.modulate = Color.WHITE

func get_is_dashing():
	return is_dashing

func shoot_fireball() -> void:
	var fb = fireball_scene.instantiate()
	fb.position = global_position + Vector2(fire_offset.x * facing.x, fire_offset.y)
	fb.direction = facing
	fb.shooter = self
	get_tree().current_scene.add_child(fb)
