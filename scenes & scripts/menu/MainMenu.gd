extends CanvasLayer


# Declare onready variables for UI components
@onready var main_menu = $Main
@onready var settings_menu = $Settings
@onready var add_players_menu = $AddPlayers
@onready var hold_x_to_start_graphic = $AddPlayers/CenterContainer/VBoxContainer/HoldXToStartGraphic
@onready var players_and_prompt = $AddPlayers/CenterContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PlayersAndPrompt
@onready var add_players_graphic = $AddPlayers/CenterContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PlayersAndPrompt/AddPlayersGraphic
@onready var main_play_button = $Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainPlayButton
@onready var setting_back_button = $Settings/CenterContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/SettingsBackButton

const PLAYER_CARD_SCENE = preload("res://scenes & scripts/menu/player_card.tscn")
const GAMEPLAY_SCENE_PATH = "res://scenes & scripts/gameplay/gameplay.tscn"


# map from player integer to the player node
var player_nodes = {}


# When the player decide to start a match, call the relevant methods on the LoadMatch singleton
func start_match():
	SoundManager.play_sound("start02", -3)
	LoadMatch.store_players(player_nodes)
	LoadMatch.begin_game_preparations()


# Add a new card representing a new player
func add_player_card(player_num):
	play_ui_next_sound(-8, 1)
	var player_card_instance = PLAYER_CARD_SCENE.instantiate()
	var player_number_label = player_card_instance.get_node("PlayerNumber")
	player_number_label.text = str(player_num)
	player_nodes[player_num] = player_card_instance
	
	# Add the new card, and adjust the 'Press A To Join' graphic to appear last
	players_and_prompt.add_child(player_card_instance)
	var last_index = players_and_prompt.get_child_count() - 1
	players_and_prompt.move_child(add_players_graphic, last_index)
	
	# If at least two players are joined, show the prompt to start the match
	if player_nodes.keys().size() >= 2:
		hold_x_to_start_graphic.visible = true


# If a player backs out, remove their card.
func remove_player_card(player_num):
	play_ui_back_sound(-8, 1)
	# Remove the associated card
	player_nodes[player_num].queue_free()
	player_nodes.erase(player_num)
	# If applicable hide the 'Press A To Join' graphic (there must be >= 2 players)
	if player_nodes.keys().size() < 2:
		hold_x_to_start_graphic.visible = false


# Show the main menu & connect the relevant signals to methods 
func _ready():
	PlayerManager.player_joined.connect(add_player_card)
	PlayerManager.player_left.connect(remove_player_card)
	
	main_menu.visible = true
	settings_menu.visible = false
	add_players_menu.visible = false
	hold_x_to_start_graphic.visible = false
	
	main_play_button.grab_focus()


# Handle player input
func _process(_delta):
	# Listen for join input, the PlayerManager will then initialize players as needed
	if add_players_menu.visible == true:
		PlayerManager.handle_join_input()
	
	# If the players want to start the match, call start_match()
	if add_players_menu.visible == true and hold_x_to_start_graphic.visible == true:
		if PlayerManager.someone_wants_to_start():
			start_match()
			play_ui_next_sound()
	
	# Back out from the add players screen
	if add_players_menu.visible == true:
		# If a particular player has hit back, remove them and their card.
		var query_player_back = PlayerManager.some_player_back()
		if not query_player_back == -999:
			PlayerManager.leave(query_player_back)
		
		# If an unconnected player presses back, go to main menu
		elif PlayerManager.some_device_back():
			# Go to main menu
			_on_add_players_back_button_pressed()
			# Remove each player card
			for player_num in player_nodes.keys():
				PlayerManager.leave(player_num)

	# Back out from the settings menu
	if settings_menu.visible == true and PlayerManager.some_device_back():
		print("Back pressed at settings")
		_on_settings_back_button_pressed()


func play_ui_next_sound(volume = -8, pitch = 1.2):
	SoundManager.play_sound("ui_next", volume, pitch)

func play_ui_back_sound(volume = -8, pitch = 1.2):
	SoundManager.play_sound("ui_back", volume, pitch)


func _on_main_play_button_pressed():
	main_menu.visible = false
	settings_menu.visible = false
	add_players_menu.visible = true
	hold_x_to_start_graphic.visible = false
	play_ui_next_sound()


func _on_main_options_button_pressed():
	main_menu.visible = false
	settings_menu.visible = true
	setting_back_button.grab_focus()
	add_players_menu.visible = false
	hold_x_to_start_graphic.visible = false
	play_ui_next_sound()


func _on_main_quit_button_pressed():
	get_tree().quit()


func _on_settings_back_button_pressed():
	main_menu.visible = true
	main_play_button.grab_focus()
	settings_menu.visible = false
	add_players_menu.visible = false
	hold_x_to_start_graphic.visible = false
	play_ui_back_sound()


func _on_add_players_back_button_pressed():
	main_menu.visible = true
	main_play_button.grab_focus()
	settings_menu.visible = false
	add_players_menu.visible = false
	hold_x_to_start_graphic.visible = false
	play_ui_back_sound()
