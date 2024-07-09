extends Node


const GAMEPLAY_SCENE_PATH = "res://scenes & scripts/gameplay/gameplay.tscn"
const PLAYER_SCENE = preload("res://scenes & scripts/gameplay/player.tscn")


# Keep track of the player nums and their corresponding player instances
var player_nodes = {}


# Create a player and add it to our player_nodes dict
func create_player(player_num):
	var player_instance = PLAYER_SCENE.instantiate()
	player_nodes[player_num] = player_instance


# Take a dictionary of players and use the player_nums to construct our own dict
func store_players(player_dict):
	for player_num in player_dict.keys():
		create_player(player_num)


# Start the match by changing scenes to the gameplay & spawning in the players
func start_match():
	# First, change the scene to the gameplay scene
	get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH)
	await get_tree().process_frame
	
	# Next, grab the groups of spawn points for both teams
	var team_one_spawns = get_tree().get_nodes_in_group("TeamOneSpawn")
	var team_two_spawns = get_tree().get_nodes_in_group("TeamTwoSpawn")
	var team_one_iterator = 0
	var team_two_iterator = 0
	
	# Finally, add in the players to the match
	for player_num in player_nodes.keys():
		get_tree().current_scene.add_child(player_nodes[player_num])
		player_nodes[player_num].init(player_num)
		if (PlayerManager.get_player_data(player_num, "team") == 1):
			# Set the player collision based on team (important for bubble & goal collision)
			player_nodes[player_num].collision_layer = 0b00000001  # Layer 1 (Team 1)
			player_nodes[player_num].collision_mask = 0b00001111 # All except goal (1-4)
			# Move this player to an applicable spawn point. Iterate to avoid spawning players together
			player_nodes[player_num].position = team_one_spawns[team_one_iterator].position
			team_one_iterator += 1
			# If we don't have enough spawn points, cycle back around and double up.
			if team_one_iterator > team_one_spawns.size() - 1: team_one_iterator = 0
		else:
			# Set the player collision based on team (important for bubble & goal collision)
			player_nodes[player_num].collision_layer = 0b00000010  # Layer 2 (Team 2)
			player_nodes[player_num].collision_mask = 0b00001111 # All except goal (1-4)
			# Move this player to an applicable spawn point. Iterate to avoid spawning players together
			player_nodes[player_num].position = team_two_spawns[team_two_iterator].position
			team_two_iterator += 1
			# If we don't have enough spawn points, cycle back around and double up.
			if team_two_iterator > team_two_spawns.size() - 1: team_two_iterator = 0
	
	# Signal that we are done; begin match logic
	get_tree().current_scene.match_ready()
