extends Area2D
@onready var sound: AudioStreamPlayer2D = $Sound

@export var speed: float = 150.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0

func _ready() -> void:
	add_to_group("fireball")

	# Collision from the fireball's own CollisionShape2D
	body_entered.connect(_on_hit)

	$AnimatedSprite2D.flip_h = direction.x < 0
	sound.play()

	$Timer.wait_time = lifetime
	$Timer.start()


func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta


var shooter = null

func _on_hit(body: Node) -> void:
	if body == shooter:
		return

	# Ice cube special interaction
	if body.is_in_group("icecube"):
		if body.has_method("start_melting"):
			body.start_melting()
		explode()
		return

	# Damage player or enemy
	if body.is_in_group("player") or body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage()

	explode()


func explode() -> void:
	# Add explosion animation here if you want
	queue_free()


func _on_Timer_timeout() -> void:
	queue_free()
