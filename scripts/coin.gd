extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	var ui = get_node("/root/Main/UI")
	ui.add_coin_to_score()
	animation_player.play("pick_up")
