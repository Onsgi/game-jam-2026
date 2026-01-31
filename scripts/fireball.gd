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
	position += direction.normalized() * speed * delta

	if $RayCast2D.is_colliding():
		var hit = $RayCast2D.get_collider()
		if hit and hit.is_in_group("icecube"):
			if hit.has_method("start_melting"):
				hit.start_melting()
		explode()


var shooter = null

func _on_hit(body: Node) -> void:
	if body == shooter: return
	print(body)
	if body.is_in_group("player") or body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage()
	explode()


func explode() -> void:
	# Add explosion animation here if you want
	queue_free()


func _on_Timer_timeout() -> void:
	queue_free()
