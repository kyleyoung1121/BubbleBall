extends Control


# Declare the dictionary with sliders and their corresponding GameSettings values
@onready var sliders = {
	"MasterVolumeSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/MasterVolumeContainer/SliderBox/MasterVolumeSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/MasterVolumeContainer/SliderBox/SliderValueBox/MasterVolumeValueText, 
		"scroll_page": 0,
		"setting": "master_volume" 
	},
	"SfxVolumeSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/SfxVolumeContainer/SliderBox/SfxVolumeSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/SfxVolumeContainer/SliderBox/SliderValueBox/SfxVolumeValueText, 
		"scroll_page": 0,
		"setting": "sfx_volume" 
	},
	"MusicVolumeSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/MusicVolumeContainer/SliderBox/MusicVolumeSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/MusicVolumeContainer/SliderBox/SliderValueBox/MusicVolumeValueText, 
		"scroll_page": 0,
		"setting": "music_volume" 
	},
	"TrackSelectSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/TrackSelectContainer/SliderBox/TrackSelectSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/TrackSelectContainer/SliderBox/SliderValueBox/TrackSelectValueText, 
		"scroll_page": 0,
		"setting": "music_track" 
	},
	"TeamLivesSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/TeamLivesContainer/SliderBox/TeamLivesSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/TeamLivesContainer/SliderBox/SliderValueBox/TeamLivesValueText, 
		"scroll_page": 1,
		"setting": "team_lives" 
	},
	"GameSpeedSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/GameSpeedContainer/SliderBox/GameSpeedSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/GameSpeedContainer/SliderBox/SliderValueBox/GameSpeedValueText, 
		"scroll_page": 1,
		"setting": "game_time_scale" 
	},
	"SlowMoSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/SlowMoSpeedContainer/SliderBox/SlowMoSpeedSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/SlowMoSpeedContainer/SliderBox/SliderValueBox/SlowMoSpeedValueText, 
		"scroll_page": 1,
		"setting": "slow_mo_scale" 
	},
	"BubbleSizeSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/BubbleSizeContainer/SliderBox/BubbleSizeSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/BubbleSizeContainer/SliderBox/SliderValueBox/BubbleSizeValueText, 
		"scroll_page": 1,
		"setting": "bubble_size" 
	},
	"SpinSpeedSlider": { 
		"slider": $Panel/ScrollContainer/VBoxContainer/SpinSpeedContainer/SliderBox/SpinSpeedSlider, 
		"value_text": $Panel/ScrollContainer/VBoxContainer/SpinSpeedContainer/SliderBox/SliderValueBox/SpinSpeedValueText, 
		"scroll_page": 2,
		"setting": "spin_speed" 
	},
}
@onready var scroll_container = $Panel/ScrollContainer

var audio_slider_names = ["MasterVolumeSlider", "SfxVolumeSlider", "MusicVolumeSlider", "TrackSelectSlider"]


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
		# Otherwise, get the slider attach a function to handle when it is updated
		var slider = slider_info["slider"]
		slider.value_changed.connect(build_slider_changed_callback(key))
		slider.focus_entered.connect(build_slider_focused_callback(key))


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
		# If the slider was a music slider, send an update to the SoundManager
		if key in audio_slider_names:
			SoundManager.update_settings()


# Given a specific slider, build a function that will adjust the correct variables on slider change
func build_slider_focused_callback(key):
	# Each time the slider changes, it will call this function
	return func on_slider_focused():
		# Based on the slider, adjust the scroll to match
		if sliders[key]["scroll_page"] == 0:
			scroll_container.scroll_vertical = 0
		elif sliders[key]["scroll_page"] == 1:
			scroll_container.scroll_vertical = 279
		elif sliders[key]["scroll_page"] == 2:
			scroll_container.scroll_vertical = 342


func focus_first_slider():
	# When the settings menu is opened, focus on the first slider
	var first_slider_name = sliders.keys()[0]
	var first_slider = sliders[first_slider_name]["slider"]
	scroll_container.scroll_vertical = 0
	first_slider.grab_focus()
