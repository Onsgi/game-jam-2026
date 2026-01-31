extends Enemy

const SPEED = 80 # Faster than green slime (50)
const JUMP = 100
var direction = 0
var velocity = Vector2.ZERO
var JUMP_VELOCITY = -350 # Higher jump
var is_jumping = false
var original_position

# Raycasts needed for movement logic
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_up_2: RayCast2D = $RayCastUp2


func _ready():
	original_position = position
	hp = 5 # Tougher
	soul_reward = 20 # More souls

func _physics_process(delta: float) -> void:
	if is_dead:
		if not animated_sprite.is_playing():
			if animated_sprite.animation_finished and animated_sprite.animation == "death":
				queue_free()
				return
			animated_sprite.play("death")
		return
	
	if ray_cast_left.is_colliding():
		animated_sprite.flip_h = true
	if ray_cast_right.is_colliding():
		animated_sprite.flip_h = false
	
	if is_jumping:
		velocity.y += 980 * delta
		position += velocity * delta
		if position.y >= original_position.y:
			position.y = original_position.y
			velocity = Vector2.ZERO
			is_jumping = false
	
	if ray_cast_up.is_colliding() or ray_cast_up_2.is_colliding():
		if not is_jumping:
			velocity.y = JUMP_VELOCITY
			is_jumping = true
		
	animated_sprite.play("idle")

# _on_body_entered inherited from Enemy, but GreenSlime overrode it for movement/damage?
# No, Enemy handles collision damage via body.take_damage() if overlapping?
# Wait, Enemy class usually detects collision via Area2D signal _on_body_entered.
# I need to connect the signal in the scene to this script (or inherit it).
# Since I'm creating a new script, I need to make sure the signal is connected.
# GreenSlime had:
# func _on_body_entered(body: Node2D) -> void:
# 	if body is Player: 
#       ...
# Enemy class didn't implement _on_body_entered! I forgot to add it to the BASE class logic 
# or I intended the subclass to handle it.
# 'green_slime.gd' has _on_body_entered logic.
# I should copy that collision logic here too.

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_death():
			return
		
		if body.get_is_dashing():
			take_damage(1)
		else:
			body.take_damage()
