extends Control

@onready var resume_button = $ColorRect/CenterContainer/VBoxContainer/ResumeButton
@onready var volume_slider = $ColorRect/CenterContainer/VBoxContainer/VolumeSlider
@onready var sfx_slider = $ColorRect/CenterContainer/VBoxContainer/SfxSlider
@onready var music_slider = $ColorRect/CenterContainer/VBoxContainer/MusicSlider
@onready var highscore = $ColorRect/CenterContainer/VBoxContainer/HighScore

var bus_index: int
var bus_index2: int
var bus_index3: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index("Master")
	bus_index2 = AudioServer.get_bus_index("sfx")
	bus_index3 = AudioServer.get_bus_index("music")
	highscore.text = "Highscore: %d" % Game_config.highscore
	volume_slider.value = Game_config.load_master_vol()
	#print(volume_slider.value)
	sfx_slider.value = Game_config.load_sfx_vol()
	music_slider.value = Game_config.load_music_vol()

func _on_resume_button_pressed() -> void:
	print("resume")
	Game_config.pause_event()

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Game_config.save_master_vol(value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index2, linear_to_db(value))
	#print(value)
	Game_config.save_sfx_vol(value)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index3, linear_to_db(value))
	Game_config.save_music_vol(value)
