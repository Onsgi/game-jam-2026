extends Control

# Name of the menu to show when the scene loads
@export var default_menu: String = "MainMenu"

func _ready():
	show_menu(default_menu)


func show_menu(menu_name: String):
	# Hide all menus, then show the one requested
	for child in get_children():
		if child is Control:
			child.visible = child.name == menu_name


# Button callbacks
func _on_play_pressed():
	print("Start game here")


func _on_options_pressed():
	show_menu("Mainlevel")
