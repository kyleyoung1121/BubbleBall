extends Control

signal close_settings

@export var page_index = 0
@export var page_order = ["Game", "VideoAudio", "Controls", "Accessibility"]

@onready var game_page = $Panel/Game
@onready var video_audio_page = $Panel/VideoAudio
@onready var controls_page = $Panel/Controls
@onready var accessibility_page = $Panel/Accessibility

@onready var page_underlines = $Panel/PageBar/PageUnderlines
@onready var scroll_up_hint = $Panel/ScrollUpHint
@onready var scroll_down_hint = $Panel/ScrollDownHint

var active_page = game_page


func _process(_delta):
	# Only check for changes if the menu is actually open (visible)
	if visible == true:
		if PlayerManager.device_button_pressed("page_next") or PlayerManager.player_button_pressed("page_next"):
			cycle_active_page("page_next")
		
		elif PlayerManager.device_button_pressed("page_previous") or PlayerManager.player_button_pressed("page_previous"):
			cycle_active_page("page_previous")
		
		if PlayerManager.device_button_pressed("back") or PlayerManager.player_button_pressed("back"):
			release_focus()
			play_ui_back_sound()
			emit_signal("close_settings")
		
		# Attempt to match the scroll to show the selected slider
		var focused_element = get_viewport().gui_get_focus_owner()
		var focused_container = focused_element.get_parent().get_parent().get_parent()
		var focused_slider_index = -1
		if focused_container in active_page.get_child(0).get_children():
			focused_slider_index = active_page.get_child(0).get_children().find(focused_container)
		
		# For every set of 6 additional sliders, we need 219 units of scroll
		@warning_ignore("integer_division")
		active_page.scroll_vertical = floor(focused_slider_index / 6) * 219
		
		# Calculate how much scroll would be needed to view all sliders
		var count_scroll_bars = active_page.get_child(0).get_children().size()
		var off_screen_scroll_bars = max(0, count_scroll_bars - 6) # About 6 fit on screen
		var max_scroll = off_screen_scroll_bars * 36.5 # Each scroll bar is about this tall
		# Check if we are scrolled to the ~bottom
		if active_page.scroll_vertical >= max_scroll:
			scroll_down_hint.visible = false
		else:
			scroll_down_hint.visible = true
		
		# Check if we are scrolled to the top
		if active_page.scroll_vertical == 0:
			scroll_up_hint.visible = false
		else:
			scroll_up_hint.visible = true


func _ready():
	show_active_page()


# When the settings menu is opened, focus on the first slider
func focus_first_element():
	# Declare variables to hold different key elements 
	var sliders_vbox 
	var first_slider_container
	var first_slider
	
	# Attempt to dig into the active page to find the first slider
	if active_page and active_page.get_children().size() > 0:
		sliders_vbox = active_page.get_child(0)
	if sliders_vbox and sliders_vbox.get_children().size() > 0:
		first_slider_container = sliders_vbox.get_child(0)
	if first_slider_container:
		first_slider = first_slider_container.get_node("HBox/SliderBox/Slider")
	if first_slider:
		first_slider.grab_focus()


func show_active_page():
	# Hide all pages & underlines
	game_page.visible = false
	video_audio_page.visible = false
	controls_page.visible = false
	accessibility_page.visible = false
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
		"Controls":
			controls_page.visible = true
			active_page = controls_page
		"Accessibility":
			accessibility_page.visible = true
			active_page = accessibility_page
		_:
			# If no match is found, default to showing the game page
			game_page.visible = true
			active_page = game_page
	
	# Reveal the correct underline if possible
	if page_underlines.get_children().size() >= page_index - 1:
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
