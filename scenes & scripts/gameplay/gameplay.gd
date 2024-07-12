extends Node2D


@onready var start_timer = $CountDownText/StartTimer
@onready var count_down_text = $CountDownText
@onready var post_round_timer = $PostRoundTimer


const ORANGE_TEAM_TEXTURE = preload("res://assets/sprites/players/orange_player.png")
const BLUE_TEAM_TEXTURE = preload("res://assets/sprites/players/blue_player.png")
const ORANGE_HEART_TEXTURE = preload("res://assets/sprites/orange_heart.png")
const BLUE_HEART_TEXTURE = preload("res://assets/sprites/blue_heart.png")
const EMPTY_HEART_TEXTURE = preload("res://assets/sprites/empty_heart.png")
const BALL_SCENE = preload("res://scenes & scripts/gameplay/ball.tscn")
const MAPS_FOLDER = "res://scenes & scripts/maps/"


# Keep track of the player nums and their corresponding player instances
var player_nodes = {}
var map_paths = []
var map_selected = null
var map_iterator = 0
var match_in_progress = false
var round_in_progress = false
var ball_instance

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
	update_player_lives()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not match_in_progress and PlayerManager.someone_button_pressed("map_select_next"):
		map_iterator += 1
		if map_iterator > map_paths.size() - 1:
			map_iterator = 0
		remove_map()
		show_map(map_paths[map_iterator])
	
	if not match_in_progress and PlayerManager.someone_button_pressed("map_select_previous"):
		map_iterator -= 1
		if map_iterator < 0:
			map_iterator = map_paths.size() - 1
		remove_map()
		show_map(map_paths[map_iterator])
	
	if not match_in_progress and PlayerManager.someone_button_pressed("ui_accept"):
		prepare_match()

func goal_scored(team):
	if round_in_progress:
		# Start post-round. Players can still move, but cannot score
		round_in_progress = false
		post_round_timer.start()
		# Add this goal to the point totals
		if team == 1: team_one_lives -= 1
		if team == 2: team_two_lives -= 1
		# Update the life totals for both players
		update_player_lives()


func reset_round():
	# Reset players & ball
	freeze_time()
	remove_players()
	remove_ball()
	remove_bubbles()
	add_ball()
	
	# If the match is over, prepare for map selection
	if team_one_lives <= 0 or team_two_lives <= 0:
		match_in_progress = false
		team_one_lives = GameSettings.team_lives
		team_two_lives = GameSettings.team_lives
		update_player_lives()
	
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


func update_player_lives():
	# Set visibility of hearts 4 & 5, as well as the extra lives text
	if team_one_lives >= 4: $OrangeHearts/Heart4.visible = true
	if team_one_lives >= 5: $OrangeHearts/Heart5.visible = true
	if team_one_lives > 5: $OrangeHearts/AdditionalHearts.visible = true
	if team_two_lives >= 4: $BlueHearts/Heart4.visible = true
	if team_two_lives >= 5: $BlueHearts/Heart5.visible = true
	if team_two_lives > 5: $BlueHearts/AdditionalHearts.visible = true

	# Set team one's life count
	if team_one_lives <= 0:
		$OrangeHearts/Heart1.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart2.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart3.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart4.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_one_lives == 1:
		$OrangeHearts/Heart1.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart2.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart3.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart4.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_one_lives == 2:
		$OrangeHearts/Heart1.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart2.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart3.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart4.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_one_lives == 3:
		$OrangeHearts/Heart1.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart2.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart3.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart4.texture = EMPTY_HEART_TEXTURE
		$OrangeHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_one_lives == 4:
		$OrangeHearts/Heart1.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart2.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart3.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart4.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_one_lives >= 5:
		$OrangeHearts/Heart1.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart2.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart3.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart4.texture = ORANGE_HEART_TEXTURE
		$OrangeHearts/Heart5.texture = ORANGE_HEART_TEXTURE
	if team_one_lives > 5:
		$OrangeHearts/AdditionalHearts.text = "+" + str(team_one_lives - 5)
	else:
		$OrangeHearts/AdditionalHearts.text = ""
	
	# Set team two's life count
	if team_two_lives <= 0:
		$BlueHearts/Heart1.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart2.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart3.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart4.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_two_lives == 1:
		$BlueHearts/Heart1.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart2.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart3.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart4.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_two_lives == 2:
		$BlueHearts/Heart1.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart2.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart3.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart4.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_two_lives == 3:
		$BlueHearts/Heart1.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart2.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart3.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart4.texture = EMPTY_HEART_TEXTURE
		$BlueHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_two_lives == 4:
		$BlueHearts/Heart1.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart2.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart3.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart4.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart5.texture = EMPTY_HEART_TEXTURE
	elif team_two_lives >= 5:
		$BlueHearts/Heart1.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart2.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart3.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart4.texture = BLUE_HEART_TEXTURE
		$BlueHearts/Heart5.texture = BLUE_HEART_TEXTURE
	if team_two_lives > 5:
		$BlueHearts/AdditionalHearts.text = "+" + str(team_two_lives - 5)
	else:
		$BlueHearts/AdditionalHearts.text = ""


func add_ball():
	ball_instance = BALL_SCENE.instantiate()
	map_selected.add_child(ball_instance)
	
	var ball_spawns = get_tree().get_nodes_in_group("BallSpawn")
	if ball_spawns:
		ball_instance.position = ball_spawns[0].position
	else:
		ball_instance.position = Vector2(323, 55)
	
	freeze_time()
	#map_selected.move_child()


func remove_ball():
	ball_instance.goal_scored.disconnect(goal_scored)
	if ball_instance != null and is_instance_valid(ball_instance):
		ball_instance.queue_free()
	for ball in get_tree().get_nodes_in_group("ball"):
		ball.queue_free()
	ball_instance = null


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


func remove_bubbles():
	for bubble in get_tree().get_nodes_in_group("Bubble"):
		bubble.queue_free()


func remove_map():
	map_selected.queue_free()
	map_selected = null
	remove_ball()


func remove_players():
	for player_num in player_nodes.keys():
		get_tree().current_scene.remove_child(player_nodes[player_num])


func match_begin():
	# Set time scale to game settings
	Engine.time_scale = GameSettings.game_time_scale
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
