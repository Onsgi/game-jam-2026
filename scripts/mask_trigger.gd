extends Area2D

@export var new_skin = "fire"
@onready var mask_sprite := $Sprite2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		Game_config.collect_mask(new_skin)
		body.switch_skin(new_skin) # call the player's skin change function
		mask_sprite.visible = false # hide mask after pickup
		queue_free() # optional: remove the pickup
