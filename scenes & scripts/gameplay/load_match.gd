extends Node

const GAMEPLAY_SCENE_PATH = "res://scenes & scripts/gameplay/gameplay.tscn"
const PLAYER_SCENE = preload("res://scenes & scripts/gameplay/player.tscn")


var player_nodes = {}


func create_player(player_num):
	var player_instance = PLAYER_SCENE.instantiate()
	player_nodes[player_num] = player_instance


func store_players(player_dict):
	for player_num in player_dict.keys():
		create_player(player_num)


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
			player_nodes[player_num].position = team_one_spawns[team_one_iterator].position
			team_one_iterator += 1
			if team_one_iterator > team_one_spawns.size() - 1: team_one_iterator = 0
		else:
			player_nodes[player_num].position = team_two_spawns[team_two_iterator].position
			team_two_iterator += 1
			if team_two_iterator > team_two_spawns.size() - 1: team_two_iterator = 0
	
	# Signal that we are done; begin match logic
	get_tree().current_scene.match_ready()
	


func _ready():
	pass

func _process(delta):
	pass
