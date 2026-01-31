extends Enemy

const SPEED = 50
var direction = 0
@onready var timer: Timer = $Timer
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_dead:
		if not $AnimatedSprite2D.is_playing():
			if $AnimatedSprite2D.animation_finished and $AnimatedSprite2D.animation == "death":
				queue_free()
				return
			$AnimatedSprite2D.play("death")
		return
	
	if ray_cast_left.is_colliding():
		$AnimatedSprite2D.flip_h = true
		direction = -1
		position.x += direction * SPEED * delta
	if ray_cast_right.is_colliding():
		$AnimatedSprite2D.flip_h = false
		direction = 1
		position.x += direction * SPEED * delta
	$AnimatedSprite2D.play("idle")
	
	

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_death():
			return
		
		if body.get_is_dashing():
			take_damage(1)
		else:
			body.take_damage()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1.0
