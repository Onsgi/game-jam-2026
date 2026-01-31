extends Area2D

const SPEED = 50
const JUMP = 100
var direction = 0
var velocity = Vector2.ZERO
var is_dead = false
var JUMP_VELOCITY = -300
var is_jumping = false
var original_position
@onready var timer: Timer = $Timer
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_up_2: RayCast2D = $RayCastUp2


func _ready():
	original_position = position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_dead:
		if not $AnimatedSprite2D.is_playing():
			if $AnimatedSprite2D.animation_finished and $AnimatedSprite2D.animation == "death":
				queue_free()
				return
			$AnimatedSprite2D.play("death")
		return
	
	
	if ray_cast_left.is_colliding():
		$AnimatedSprite2D.flip_h = true
	if ray_cast_right.is_colliding():
		$AnimatedSprite2D.flip_h = false
	
	if is_jumping:
		velocity.y += gravity * delta
		position += velocity * delta
		if position.y >= original_position.y:
			position.y = original_position.y
			velocity = Vector2.ZERO
			is_jumping = false
	
	if ray_cast_up.is_colliding() or ray_cast_up_2.is_colliding():
		if not is_jumping:
			velocity.y = JUMP_VELOCITY
			is_jumping = true
		
	$AnimatedSprite2D.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_death():
			return
		
		if body.get_is_dashing():
			is_dead = true
		else:
			body.set_death()
			Engine.time_scale = 0.5
			timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1.0
