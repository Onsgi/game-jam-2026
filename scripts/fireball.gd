extends Area2D

@onready var sound: AudioStreamPlayer2D = $Sound

@export var speed: float = 150.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0

var shooter = null

func _ready() -> void:
	add_to_group("fireball")

	# Ensure monitoring is enabled
	monitoring = true
	monitorable = true

	# Detect both bodies and areas
	body_entered.connect(_on_hit)
	area_entered.connect(_on_area_hit)

	$AnimatedSprite2D.flip_h = direction.x < 0
	sound.play()

	$Timer.wait_time = lifetime
	$Timer.start()

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta

func _on_hit(body: Node) -> void:
	if body == shooter:
		return

	if body.is_in_group("icecube"):
		body.start_melting()
		explode()
		return

	if body.is_in_group("player") or body.is_in_group("enemy"):
		body.take_damage(1)
		explode()
	else:
		# Hit a wall or something else
		explode()

func _on_area_hit(area: Area2D) -> void:
	if area == shooter:
		return

	if area.is_in_group("icecube"):
		area.start_melting()
		explode()

func explode() -> void:
	queue_free()

func _on_Timer_timeout() -> void:
	queue_free()
