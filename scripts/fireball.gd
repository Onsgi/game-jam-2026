extends Area2D
@onready var sound: AudioStreamPlayer2D = $Sound

@export var speed: float = 250.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0

func _ready() -> void:
	add_to_group("fireball")
	body_entered.connect(_on_hit)
	$AnimatedSprite2D.flip_h = direction.x < 0
	
	sound.play()

	$Timer.wait_time = lifetime
	$Timer.start()

	# Make RayCast2D face the direction of travel
	$RayCast2D.target_position = direction.normalized() * 20.0
	$RayCast2D.enabled = true


func _physics_process(delta: float) -> void:
	# Move forward
	position += direction.normalized() * speed * delta

	# Stop if RayCast2D detects something
	if $RayCast2D.is_colliding():
		explode()


func _on_hit(body: Node) -> void:
	print("hit")
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage()
	explode()


func explode() -> void:
	# Add explosion animation here if you want
	queue_free()


func _on_Timer_timeout() -> void:
	queue_free()
