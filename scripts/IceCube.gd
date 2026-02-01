extends RigidBody2D

@export var melt_time: float = 0.8

var melting: bool = false
var elapsed: float = 0.0
var start_scale: Vector2

func _ready() -> void:
	add_to_group("icecube")
	start_scale = scale

	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	# Ensure Area2D is monitoring
	$Area2D.monitoring = true
	$Area2D.monitorable = true
	$Area2D.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if melting:
		return

	if area.is_in_group("fireball"):
		start_melting()

func start_melting() -> void:
	melting = true
	elapsed = 0.0

	$CollisionShape2D.set_deferred("disabled", true)

	for body in $Area2D.get_overlapping_bodies():
		if body is RigidBody2D:
			body.sleeping = false

	# Allow gravity again
	freeze = false


func _process(delta: float) -> void:
	if not melting:
		return

	elapsed += delta
	var t: float = clamp(elapsed / melt_time, 0.0, 1.0)

	# shrink
	scale = start_scale.lerp(Vector2.ZERO, t)

	# fade
	var sprite := $Sprite2D
	var new_color: Color = sprite.modulate
	new_color.a = lerp(1.0, 0.0, t)
	sprite.modulate = new_color

	if t >= 1.0:
		queue_free()
