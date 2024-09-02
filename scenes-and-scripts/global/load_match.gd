extends Node


const GAMEPLAY_SCENE_PATH = "res://scenes-and-scripts/gameplay/gameplay.tscn"
const PLAYER_SCENE = preload("res://scenes-and-scripts/gameplay/player.tscn")



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


func remove_all_players():
	for player_num in player_nodes.keys():
		if player_nodes.has(player_num):
			player_nodes.erase(player_num)


# Start the match by changing scenes to the gameplay & spawning in the players
func begin_game_preparations():
	# First, change the scene to the gameplay scene
	get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH)
	await get_tree().process_frame
	
	get_tree().current_scene.player_nodes = player_nodes
