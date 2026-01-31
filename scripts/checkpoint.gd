extends Area2D

var activated = false
@onready var sprite = $Sprite2D

func _on_body_entered(body):
	if body is Player and not activated:
		activated = true
		Game_config.last_checkpoint_position = global_position
		Game_config.has_checkpoint = true
		print("Checkpoint activated at: ", global_position)
		if sprite:
			sprite.modulate = Color(0, 1, 0) # Turn green
