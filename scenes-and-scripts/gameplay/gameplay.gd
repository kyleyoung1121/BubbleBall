extends Node2D

@onready var start_timer = $CountDownText/StartTimer
@onready var count_down_text = $CountDownText
@onready var next_map_symbol = $NextMapSymbol
@onready var previous_map_symbol = $PreviousMapSymbol
@onready var post_round_timer = $PostRoundTimer
@onready var post_match_timer = $PostMatchTimer
@onready var orange_hearts = $OrangeHearts
@onready var blue_hearts = $BlueHearts
@onready var pause_menu = $PauseMenu

const MAIN_MENU_SCENE_PATH = "res://scenes-and-scripts/menu/main_menu.tscn"
const ORANGE_TEAM_TEXTURE = preload("res://assets/sprites/players/orange_player.png")
const BLUE_TEAM_TEXTURE = preload("res://assets/sprites/players/blue_player.png")
const ORANGE_HEART_TEXTURE = preload("res://assets/sprites/orange_heart.png")
const BLUE_HEART_TEXTURE = preload("res://assets/sprites/blue_heart.png")
const EMPTY_HEART_TEXTURE = preload("res://assets/sprites/empty_heart.png")
const BALL_SCENE = preload("res://scenes-and-scripts/gameplay/ball.tscn")
const MAPS_FOLDER = "res://scenes-and-scripts/maps/"

# Keep track of the player nums and their corresponding player instances
var player_nodes = {}
var map_paths = []
var map_selected = null
var map_iterator = 0
var round_paused = false
var block_pause = true
var match_in_progress = false
var round_in_progress = false
var block_match_start = false
var ball_instance

var max_lives = GameSettings.team_lives
var team_one_lives
var team_two_lives

var bounds = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	# Attempt to open the maps folder
	var dir = DirAccess.open(MAPS_FOLDER)
	if dir:
		# Begin reading the directory contents
		dir.list_dir_begin()
		var file_name = dir.get_next()
		# Loop through all items in the directory
		while file_name != "":
			# Check if the item is a file (not a directory)
			if !dir.current_is_dir():
				# Append the full path of the map file to the list
				map_paths.append(MAPS_FOLDER + file_name)
			# Get the next item in the directory
			file_name = dir.get_next()
		# End the directory listing
		dir.list_dir_end()
	
	# Show the initial map
	show_map(map_paths[map_iterator])
	
	# Set the team lives
	team_one_lives = GameSettings.team_lives
	team_two_lives = GameSettings.team_lives
	update_all_hearts()
	
	# Make sure the next and previous map symbols are visible to start
	next_map_symbol.visible = true
	previous_map_symbol.visible = true
	pause_menu.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Testing: Show FPS
	$FpsCounter.text = str(Engine.get_frames_per_second())
	
	# Input handling before the match, during match select
	if not match_in_progress and not block_match_start:
		if PlayerManager.player_button_pressed("map_select_next"):
			map_iterator += 1
			if map_iterator > map_paths.size() - 1:
				map_iterator = 0
			SoundManager.play_sound("ui_next")
			remove_map()
			show_map(map_paths[map_iterator])
		
		if PlayerManager.player_button_pressed("map_select_previous"):
			map_iterator -= 1
			if map_iterator < 0:
				map_iterator = map_paths.size() - 1
			SoundManager.play_sound("ui_next")
			remove_map()
			show_map(map_paths[map_iterator])
		
		if PlayerManager.player_button_pressed("ui_accept"):
			prepare_match()
			next_map_symbol.visible = false
			previous_map_symbol.visible = false
			SoundManager.play_sound("start01")
		
		if PlayerManager.player_button_pressed("back"):
			PlayerManager.remove_all_players()
			LoadMatch.remove_all_players()
			remove_players()
			remove_map()
			SoundManager.play_sound("ui_back")
			get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
	
	# Input handling during the match
	if round_in_progress:
		# If the player presses pause and is allowed, pause. (Time scale becomes 0)
		if not block_pause and PlayerManager.player_button_pressed("pause"):
			toggle_pause()
		# Allow back button to unpause
		if round_paused and PlayerManager.player_button_pressed("back"):
			toggle_pause()


func goal_scored(team):
	if round_in_progress:
		# Start post-round. Players can still move, but cannot score
		round_in_progress = false
		post_round_timer.start()
		# Add this goal to the point totals
		if team == 1: team_one_lives -= 1
		if team == 2: team_two_lives -= 1
		# Update the life totals for both players
		update_all_hearts()
		# Play the corresponding sound effect
		SoundManager.play_sound("goal")


func reset_round():
	# Reset players & ball
	freeze_time()
	remove_players()
	remove_ball()
	remove_bubbles()
	add_ball()
	
	# Do not allow players to pause until they are able to move
	block_pause = true
	
	# If the match is over, prepare for map selection
	if team_one_lives <= 0 or team_two_lives <= 0:
		match_in_progress = false
		team_one_lives = GameSettings.team_lives
		team_two_lives = GameSettings.team_lives
		update_all_hearts()
		SoundManager.play_sound("win")
		next_map_symbol.visible = true
		previous_map_symbol.visible = true
		block_match_start = true
		post_match_timer.start()
	
	# If there are still rounds to play, start a new one
	else:
		round_in_progress = true
		prepare_match()


func prepare_match():
	# Disable map selection
	match_in_progress = true
	round_in_progress = true
	
	# Find the ball and connect its goal signal to the goal_scored method here.
	ball_instance.goal_scored.connect(goal_scored)
	
	# Grab the groups of spawn points for both teams
	var team_one_spawns = get_tree().get_nodes_in_group("TeamOneSpawn")
	var team_two_spawns = get_tree().get_nodes_in_group("TeamTwoSpawn")
	var team_one_iterator = 0
	var team_two_iterator = 0
	
	# Add in the players to the match
	for player_num in player_nodes.keys():
		get_tree().current_scene.add_child(player_nodes[player_num])
		player_nodes[player_num].init(player_num)
		if (PlayerManager.get_player_data(player_num, "team") == 1):
			# Set the player collision based on team (important for bubble & goal collision)
			player_nodes[player_num].collision_layer = 0b00000001  # Layer 1 (Team 1)
			player_nodes[player_num].collision_mask = 0b00001111 # All except goal (1-4)
			# Move this player to an applicable spawn point. Iterate to avoid spawning players together
			player_nodes[player_num].position = team_one_spawns[team_one_iterator].position
			# Set the players sprite to match their team
			player_nodes[player_num].get_node("Sprite2D").texture = ORANGE_TEAM_TEXTURE
			team_one_iterator += 1
			# If we don't have enough spawn points, cycle back around and double up.
			if team_one_iterator > team_one_spawns.size() - 1: team_one_iterator = 0
		else:
			# Set the player collision based on team (important for bubble & goal collision)
			player_nodes[player_num].collision_layer = 0b00000010  # Layer 2 (Team 2)
			player_nodes[player_num].collision_mask = 0b00001111 # All except goal (1-4)
			# Move this player to an applicable spawn point. Iterate to avoid spawning players together
			player_nodes[player_num].position = team_two_spawns[team_two_iterator].position
			# Set the players sprite to match their team
			player_nodes[player_num].get_node("Sprite2D").texture = BLUE_TEAM_TEXTURE
			team_two_iterator += 1
			# If we don't have enough spawn points, cycle back around and double up.
			if team_two_iterator > team_two_spawns.size() - 1: team_two_iterator = 0
	
	freeze_time()
	
	# Set time scale to normal
	Engine.time_scale = 1
	start_timer.start()
	SoundManager.play_sound("countdown")


# Pause the game. Uses game_time_scale instead of freezing to preserve momentum
func toggle_pause():
	if round_paused:
		# Unpause
		Engine.time_scale = GameSettings.game_time_scale
		pause_menu.visible = false
		round_paused = false
		# Check to see if the team_lives changed. If so, add/remove lives.
		if not GameSettings.team_lives == max_lives:
			team_one_lives += GameSettings.team_lives - max_lives
			team_two_lives += GameSettings.team_lives - max_lives
		max_lives = GameSettings.team_lives
		# Update hearts to match current settings
		update_all_hearts()
		SoundManager.play_sound("ui_back")
		
		
		
	else:
		# Pause
		Engine.time_scale = 0.00000000000001
		pause_menu.visible = true
		pause_menu.reload_slider_values()
		pause_menu.focus_first_slider()
		round_paused = true
		SoundManager.play_sound("ui_next")


# Function to update hearts for a given team
func update_team_hearts(team_lives, heart_nodes, heart_texture):
	for i in range(5):
		heart_nodes[i].texture = heart_texture if team_lives > i else EMPTY_HEART_TEXTURE
	
	# Set visibility of extra hearts and additional text
	heart_nodes[3].visible = GameSettings.team_lives >= 4
	heart_nodes[4].visible = GameSettings.team_lives >= 5
	heart_nodes[5].visible = GameSettings.team_lives > 5
	heart_nodes[5].text = "+" + str(team_lives - 5) if team_lives > 5 else ""


func update_all_hearts():
	# Array of heart nodes for each team
	var orange_heart_nodes = [
		orange_hearts.get_node("Heart1"),
		orange_hearts.get_node("Heart2"),
		orange_hearts.get_node("Heart3"),
		orange_hearts.get_node("Heart4"),
		orange_hearts.get_node("Heart5"),
		orange_hearts.get_node("AdditionalHearts")
	]

	var blue_heart_nodes = [
		blue_hearts.get_node("Heart1"),
		blue_hearts.get_node("Heart2"),
		blue_hearts.get_node("Heart3"),
		blue_hearts.get_node("Heart4"),
		blue_hearts.get_node("Heart5"),
		blue_hearts.get_node("AdditionalHearts")
	]

	# Update hearts for both teams
	update_team_hearts(team_one_lives, orange_heart_nodes, ORANGE_HEART_TEXTURE)
	update_team_hearts(team_two_lives, blue_heart_nodes, BLUE_HEART_TEXTURE)


func show_map(map_path):
	# Add map to scene
	var loaded_map = load(map_path)
	map_selected = loaded_map.instantiate()
	get_parent().add_child(map_selected)
	bounds["max_x"] = get_tree().get_nodes_in_group("MaxX")[0].position.x
	bounds["min_x"] = get_tree().get_nodes_in_group("MinX")[0].position.x
	bounds["max_y"] = get_tree().get_nodes_in_group("MaxY")[0].position.y
	bounds["min_y"] = get_tree().get_nodes_in_group("MinY")[0].position.y
	freeze_time()
	add_ball()


func remove_map():
	map_selected.queue_free()
	map_selected = null
	remove_ball()


func add_ball():
	ball_instance = BALL_SCENE.instantiate()
	map_selected.add_child(ball_instance)
	
	var ball_spawns = get_tree().get_nodes_in_group("BallSpawn")
	if ball_spawns and ball_spawns.size() >= 1:
		ball_instance.position = ball_spawns.pop_back().position
	else:
		ball_instance.position = Vector2(323, 55)
	
	# Apply game settings to the ball
	ball_instance.resize_ball(GameSettings.ball_scale)
	ball_instance.mass = GameSettings.ball_mass
	
	freeze_time()


func remove_ball():
	if ball_instance.goal_scored.is_connected(goal_scored):
		ball_instance.goal_scored.disconnect(goal_scored)
	
	if ball_instance != null and is_instance_valid(ball_instance):
		ball_instance.queue_free()
	for ball in get_tree().get_nodes_in_group("ball"):
		ball.queue_free()
	ball_instance = null


func remove_bubbles():
	for bubble in get_tree().get_nodes_in_group("Bubble"):
		bubble.queue_free()


func remove_players():
	for player_num in player_nodes.keys():
		get_tree().current_scene.remove_child(player_nodes[player_num])


func match_begin():
	# Set time scale to game settings
	Engine.time_scale = GameSettings.game_time_scale
	# Players may now pause
	block_pause = false
	# Ensure each player & ball knows the bounds of the screenwrap
	for player_num in player_nodes.keys():
			player_nodes[player_num].set_bounds(bounds)
	ball_instance.set_bounds(bounds)
	unfreeze_time()


func freeze_time():
	# Freeze players
	for player_num in player_nodes.keys():
		player_nodes[player_num].freeze = true
	# Freeze ball(s)
	for node in get_tree().get_nodes_in_group("ball"):
		if node is RigidBody2D:
			node.freeze = true


func unfreeze_time():
	# Unfreeze players
	for player_num in player_nodes.keys():
		player_nodes[player_num].freeze = false
	# Unfreeze ball(s)
	for node in get_tree().get_nodes_in_group("ball"):
		if node is RigidBody2D:
			node.freeze = false


func _on_post_match_timer_timeout():
	block_match_start = false
