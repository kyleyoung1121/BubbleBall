extends Control

signal close_settings

@export var page_index = 0
@export var page_order = ["Game", "VideoAudio"]

@onready var game_page = $Panel/Game
@onready var video_audio_page = $Panel/VideoAudio

@onready var page_underlines = $Panel/PageBar/PageUnderlines

var active_page = game_page


func _process(_delta):
	# Only check for input when the settings screen is visible
	if visible == true:
		if PlayerManager.device_button_pressed("page_next") or PlayerManager.player_button_pressed("page_next"):
			cycle_active_page("page_next")
		
		elif PlayerManager.device_button_pressed("page_previous") or PlayerManager.player_button_pressed("page_previous"):
			cycle_active_page("page_previous")
		
		if PlayerManager.device_button_pressed("back") or PlayerManager.player_button_pressed("back"):
			release_focus()
			play_ui_back_sound()
			emit_signal("close_settings")


func _ready():
	show_active_page()


func focus_first_element():
	# When the settings menu is opened, focus on the first slider
	var sliders_vbox = active_page.get_child(0)
	var first_slider_container = sliders_vbox.get_child(0)
	var first_slider = first_slider_container.get_node("HBox/SliderBox/Slider")
	active_page.scroll_vertical = 0
	first_slider.grab_focus()


func show_active_page():
	# Hide all pages & underlines
	game_page.visible = false
	video_audio_page.visible = false
	for underline in page_underlines.get_children():
		underline.visible = false
	
	# Reveal the correct page
	match page_order[page_index]:
		"Game":
			game_page.visible = true
			active_page = game_page
		"VideoAudio":
			video_audio_page.visible = true
			active_page = video_audio_page
		_:
			# If no match is found, default to showing the game page
			game_page.visible = true
	
	# Reveal the correct underline
	page_underlines.get_children()[page_index].visible = true
	
	# Finally, focus the first slider on the correct page
	focus_first_element()


func cycle_active_page(direction):
	play_ui_next_sound(-10)
	
	if direction == "page_next":
		# Increment page, looping back to zero if already on the last page
		page_index += 1
		if page_index >= page_order.size():
			page_index = 0
		show_active_page()
	
	elif direction == "page_previous":
		# Decrement page, looping to the final element if on page 0
		page_index -= 1
		if page_index < 0:
			page_index = page_order.size() - 1
		show_active_page()


func jump_to_new_page(page_name):
	var new_page_index = page_order.find(page_name)
	if new_page_index == -1:
		return
	else:
		page_index = new_page_index
		show_active_page()


func _on_rb_button_button_up():
	cycle_active_page("page_next")


func _on_lb_button_button_up():
	cycle_active_page("page_previous")


func _on_game_page_button_button_up():
	jump_to_new_page("Game")
	play_ui_next_sound()


func _on_video_audio_page_button_button_up():
	jump_to_new_page("VideoAudio")
	play_ui_next_sound()


func _on_controls_page_button_button_up():
	jump_to_new_page("Controls")
	play_ui_next_sound()


func _on_accessibility_page_button_button_up():
	jump_to_new_page("Accessibility")
	play_ui_next_sound()


func _on_settings_back_button_button_up():
	play_ui_back_sound()
	emit_signal("close_settings")


func play_ui_next_sound(volume_change = 0.0, pitch_change = 1.0):
	SoundManager.play_sound("ui_next", volume_change, pitch_change)


func play_ui_back_sound(volume_change = 0.0, pitch_change = 1.0):
	SoundManager.play_sound("ui_back", volume_change, pitch_change)
