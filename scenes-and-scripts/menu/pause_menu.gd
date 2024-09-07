extends Control

signal resume_match
signal open_settings
signal quit_match

@onready var resume_button = $Panel/ResumeButton


func focus_first_element():
	resume_button.grab_focus()


func _on_resume_button_button_up():
	release_focus()
	emit_signal("resume_match")


func _on_settings_button_button_up():
	release_focus()
	play_ui_next_sound()
	emit_signal("open_settings")


func _on_quit_button_button_up():
	release_focus()
	play_ui_back_sound()
	emit_signal("quit_match")


func play_ui_next_sound(volume_change = 0.0, pitch_change = 1.0):
	SoundManager.play_sound("ui_next", volume_change, pitch_change)


func play_ui_back_sound(volume_change = 0.0, pitch_change = 1.0):
	SoundManager.play_sound("ui_back", volume_change, pitch_change)
