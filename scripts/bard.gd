extends Area2D

@onready var label: Label = $Label
@onready var player = get_node("/root/Main/Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if player.position.x < position.x:
		$AnimatedSprite2D.flip_h = true
	if player.position.x > position.x:
		$AnimatedSprite2D.flip_h = false
	pass


func _on_body_entered(body: Node2D) -> void:
	label.visible = true
	pass # Replace with function body.
