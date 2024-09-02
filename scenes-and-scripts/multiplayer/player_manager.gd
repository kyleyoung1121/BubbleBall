extends Node


# player is 0-3
# device is -1 for keyboard/mouse, 0+ for joypads
# these concepts seem similar but it is useful to separate them so for example, device 6 could control player 1.


signal player_joined(player)
signal player_left(player)
signal player_changed_team()


# player_num -> dictionary of data
var player_data: Dictionary = {}


const MAX_PLAYERS = 8


#  #  #  #  #  #  #  #  #  #  #  #  #
# FUNCTIONS FOR INPUT HANDLING

# call this from a loop in the main menu or anywhere they can join
# this is an example of how to look for an action on all devices
func handle_join_input():
	for device in get_unjoined_devices():
		if MultiplayerInput.is_action_just_pressed(device, "join"):
			join(device)


# Check if any player(s) are trying to change teams. Update their data accordingly
func handle_team_change_requests():
	# Check each player. Get input data regarding if they pressed next or previous
	for player in player_data.keys():
		var device = get_player_device(player)
		var pressed_team_swap = MultiplayerInput.is_action_just_pressed(device, "team_swap")
		var pressed_next = MultiplayerInput.is_action_just_pressed(device, "map_select_next")
		var pressed_previous = MultiplayerInput.is_action_just_pressed(device, "map_select_previous")
		
		# If this player has pressed next or previous, we can swap their team
		if pressed_team_swap or pressed_next or pressed_previous:
			print("device:", device, " pressed next team")
			var current_team = get_player_data(player, "team")
			var new_team = (current_team % 2) + 1
			set_player_data(player, "team", new_team)
			# After swapping teams, emit this signal so the UI can change accordingly
			player_changed_team.emit()


# If any device is pressing a certain button, return true
func device_button_pressed(button) -> bool:
	for device in get_unjoined_devices():
		if MultiplayerInput.is_action_just_pressed(device, button):
			print("device: ", device, " pressed ", button)
			return true
	return false


# Check if a player is pressing a button. Return that player's number, or 0 if false.
func player_button_pressed(button) -> int:
	for player in player_data:
		var device = get_player_device(player)
		if MultiplayerInput.is_action_just_pressed(device, button):
			print("player: ", player, " pressed ", button)
			return player
	# If no player is pressing the button, return 0
	return 0


#  #  #  #  #  #  #  #  #  #  #  #  #
# FUNCTIONS REQUIRED FOR BASIC USE

func join(device: int):
	var player = next_player()
	if player >= 0:
		# initialize default player data here
		player_data[player] = {
			"device": device,
			"team": ((player + 1) % 2) + 1, # Alternate between team 1 and team 2
			"current_bubble": null
		}
		player_joined.emit(player)

func leave(player: int):
	if player_data.has(player):
		player_data.erase(player)
		player_left.emit(player)

func remove_all_players():
	for player in player_data.keys():
		leave(player)

func get_player_count():
	return player_data.size()

func get_player_indexes():
	return player_data.keys()

func get_player_device(player: int) -> int:
	return get_player_data(player, "device")

# get player data.
# null means it doesn't exist.
func get_player_data(player: int, key: StringName):
	if player_data.has(player) and player_data[player].has(key):
		return player_data[player][key]
	return null

# set player data to get later
func set_player_data(player: int, key: StringName, value: Variant):
	# if this player is not joined, don't do anything:
	if !player_data.has(player):
		return
	
	player_data[player][key] = value

func is_device_joined(device: int) -> bool:
	for player_id in player_data:
		var d = get_player_device(player_id)
		if device == d: return true
	return false

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func next_player() -> int:
	for i in range(1, MAX_PLAYERS + 1):
		if !player_data.has(i): return i
	return -1

# returns an array of all valid devices that are *not* associated with a joined player
func get_unjoined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	
	# filter out devices that are joined:
	return devices.filter(func(device): return !is_device_joined(device))
