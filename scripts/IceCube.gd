extends RigidBody2D

@export var melt_time: float = 0.8

var melting: bool = false
var elapsed: float = 0.0
var start_scale: Vector2

func _ready() -> void:
	add_to_group("icecube")
	start_scale = scale
	$Area2D.area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if melting:
		return

	if area.is_in_group("fireball"):
		print("1")
		start_melting()


func start_melting() -> void:
	melting = true
	elapsed = 0.0

	# Disable physics collision so it no longer blocks anything
	$CollisionShape2D.disabled = true

	# Optional: freeze the body so it doesn't fall while melting
	freeze = true


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
