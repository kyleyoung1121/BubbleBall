extends MarginContainer

@export var title = "Game Setting"
@export var game_setting = ""
@export var game_setting_category = ""
@export var true_text = "On"
@export var false_text = "Off"

@onready var check_box = $HBox/CheckBoxContainer/MarginContainer/CheckBox
@onready var check_box_title_label = $HBox/CheckBoxTitle
@onready var check_box_value_text = $HBox/CheckBoxContainer/CheckBoxValueBox/CheckBoxValueText

var sound_settings = ["master_volume", "sfx_volume", "music_volume", "music_track", "mute"]

var freeze_settings = true


func _ready():
	freeze_settings = true
	
	check_box_title_label.text = title
	
	# If this setting is on its own, simply try to find it in GameSettings and initialize accordingly
	if not game_setting_category:
		if game_setting in GameSettings:
			check_box.button_pressed = GameSettings.get(game_setting)
			if GameSettings.get(game_setting):
				check_box_value_text.text = true_text
			else:
				check_box_value_text.text = false_text
	
	# Otherwise, use the category and try to pull this particular setting out of it
	else:
		if game_setting_category in GameSettings:
			if game_setting in GameSettings.get(game_setting_category):
				check_box.button_pressed = GameSettings.get(game_setting_category).get(game_setting)
				if GameSettings.get(game_setting_category).get(game_setting):
					check_box_value_text.text = true_text
				else:
					check_box_value_text.text = false_text
	
	freeze_settings = false


func _on_setting_value_changed(value):
	if not freeze_settings:
		
		# Update the value text
		if value:
			check_box_value_text.text = true_text
		else:
			check_box_value_text.text = false_text
		
		# Update the game setting to match the new change
		if not game_setting_category:
			GameSettings.set(game_setting, value)
		
		elif game_setting_category in GameSettings and game_setting in GameSettings.get(game_setting_category):
			var category_copy = GameSettings.get(game_setting_category)
			category_copy[game_setting] = value
			GameSettings.set(game_setting_category, category_copy)
		
		if game_setting in sound_settings:
			SoundManager.update_settings()
