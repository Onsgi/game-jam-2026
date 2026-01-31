extends Button

const LEVEL_1 = preload("res://scenes/Level1.tscn")

func _pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_1)
