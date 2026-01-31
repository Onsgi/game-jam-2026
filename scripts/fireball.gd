extends Area2D

@export var speed: float = 400.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0

func _ready() -> void:
	add_to_group("fireball")
	$Timer.wait_time = lifetime
	$Timer.start()
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta


func _on_body_entered(body: Node) -> void:
	# You can add explosion effects here if you want
	queue_free()


func _on_Timer_timeout() -> void:
	queue_free()
