extends Area2D

@export_file("*.tscn") var next_scene_path: String = "res://scenes/Level2.tscn"

func _on_body_entered(body):
	if body is Player:
		if next_scene_path != "":
			# Optional: Treat level transition as a checkpoint?
			# Game_config.last_checkpoint_position = Vector2.ZERO # Reset pos? 
			# Or let level design handle it.
			# For now, just change scene.
			call_deferred("change_scene")

func change_scene():
	get_tree().change_scene_to_file(next_scene_path)
