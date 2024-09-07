extends MarginContainer

@export var title = "Game Setting"
@export var game_setting = ""
@export var min_value = 0.0
@export var max_value = 100.0
@export var step = 1.0

@onready var slider = $HBox/SliderBox/Slider
@onready var slider_title_label = $HBox/SliderTitle
@onready var slider_value_text = $HBox/SliderBox/SliderValueBox/SliderValueText

var sound_settings = ["master_volume", "sfx_volume", "music_volume", "music_track"]

var freeze_sliders = true

func _ready():
	freeze_sliders = true
	
	slider_title_label.text = title
	
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	
	if game_setting in GameSettings:
		slider.value = GameSettings.get(game_setting)
		slider_value_text.text = str(GameSettings.get(game_setting))
	
	freeze_sliders = false


func _on_slider_value_changed(value):
	if not freeze_sliders:
		slider_value_text.text = str(value)
		GameSettings.set(game_setting, value)
		if game_setting in sound_settings:
			SoundManager.update_settings()
