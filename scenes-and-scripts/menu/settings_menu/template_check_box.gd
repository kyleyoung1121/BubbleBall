extends MarginContainer

@export var title = "Game Setting"
@export var game_setting = ""
@export var true_text = "On"
@export var false_text = "Off"

@onready var check_box = $HBox/CheckBoxContainer/MarginContainer/CheckBox
@onready var check_box_title_label = $HBox/CheckBoxTitle
@onready var check_box_value_text = $HBox/CheckBoxContainer/CheckBoxValueBox/CheckBoxValueText

var freeze_settings = true

func _ready():
	freeze_settings = true
	
	check_box_title_label.text = title
	
	if game_setting in GameSettings:
		check_box.button_pressed = GameSettings.get(game_setting)
		if GameSettings.get(game_setting):
			check_box_value_text.text = true_text
		else:
			check_box_value_text.text = false_text
	
	freeze_settings = false


func _on_setting_value_changed(value):
	if not freeze_settings:
		
		if value:
			check_box_value_text.text = true_text
		else:
			check_box_value_text.text = false_text
		
		GameSettings.set(game_setting, value)
