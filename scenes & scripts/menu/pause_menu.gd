extends Control


# Declare the dictionary with sliders and their corresponding GameSettings values
@onready var sliders = {
	"MasterVolumeSlider": { "slider": $Panel/ScrollContainer/VBoxContainer/MasterVolumeContainer/SliderBox/MasterVolumeSlider, "value_text": $Panel/ScrollContainer/VBoxContainer/MasterVolumeContainer/SliderBox/SliderValueBox/MasterVolumeValueText, "setting": "master_volume" },
	"MusicVolumeSlider": { "slider": $Panel/ScrollContainer/VBoxContainer/MusicVolumeContainer/SliderBox/MusicVolumeSlider, "value_text": $Panel/ScrollContainer/VBoxContainer/MusicVolumeContainer/SliderBox/SliderValueBox/MusicVolumeValueText, "setting": "music_volume" },
	"SfxVolumeSlider": { "slider": $Panel/ScrollContainer/VBoxContainer/SfxVolumeContainer/SliderBox/SfxVolumeSlider, "value_text": $Panel/ScrollContainer/VBoxContainer/SfxVolumeContainer/SliderBox/SliderValueBox/SfxVolumeValueText, "setting": "sfx_volume" },
	"TeamLivesSlider": { "slider": $Panel/ScrollContainer/VBoxContainer/TeamLivesContainer/SliderBox/TeamLivesSlider, "value_text": $Panel/ScrollContainer/VBoxContainer/TeamLivesContainer/SliderBox/SliderValueBox/TeamLivesValueText, "setting": "team_lives" },
	"GameSpeedSlider": { "slider": $Panel/ScrollContainer/VBoxContainer/GameSpeedContainer/SliderBox/GameSpeedSlider, "value_text": $Panel/ScrollContainer/VBoxContainer/GameSpeedContainer/SliderBox/SliderValueBox/GameSpeedValueText, "setting": "game_time_scale" },
	"SlowMoSlider": { "slider": $Panel/ScrollContainer/VBoxContainer/SlowMoSpeedContainer/SliderBox/SlowMoSpeedSlider, "value_text": $Panel/ScrollContainer/VBoxContainer/SlowMoSpeedContainer/SliderBox/SliderValueBox/SlowMoSpeedValueText, "setting": "slow_mo_scale" },
	"BubbleSizeSlider": { "slider": $Panel/ScrollContainer/VBoxContainer/BubbleSizeContainer/SliderBox/BubbleSizeSlider, "value_text": $Panel/ScrollContainer/VBoxContainer/BubbleSizeContainer/SliderBox/SliderValueBox/BubbleSizeValueText, "setting": "bubble_size" }
}


func _ready():
	reload_slider_values()
	connect_sliders()


# For each slider, check GameSettings for the defaults and set accordingly
func reload_slider_values():
	for key in sliders.keys():
		var slider_info = sliders[key]
		var slider = slider_info["slider"]
		var value_text = slider_info["value_text"]
		var setting_name = slider_info["setting"]
		var value = GameSettings.get(setting_name)
		
		slider.value = value
		value_text.text = str(value)


# Attach each slider to a function that will handle updating the game settings and UI
func connect_sliders():
	for key in sliders.keys():
		var slider_info = sliders[key]
		var slider = slider_info["slider"]
		slider.value_changed.connect(build_slider_changed_callback(key))


# Given a specific slider, build a function that will adjust the correct variables on slider change
func build_slider_changed_callback(key):
	# Each time the slider changes, it will call this function
	return func on_slider_value_changed(value):
		var slider_info = sliders[key]
		var value_text = slider_info["value_text"]
		var setting_name = slider_info["setting"]
		# Update the UI and set the game variables.
		value_text.text = str(value)
		GameSettings.set(setting_name, value)
