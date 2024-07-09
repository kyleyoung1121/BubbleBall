extends RigidBody2D


const BUBBLE_SCENE = preload("res://scenes & scripts/gameplay/bubble.tscn")


const SPEED = 550.0
const JUMP_VELOCITY = -60.0
const DRAFT = -0.75
const MAX_SPEED_X = 200.0
const MAX_SPEED_Y_RISING = 300.0
const MAX_SPEED_Y_FALLING = 500.0


var team_name = 0
var player: int
var input


# call this function when spawning this player to set up the input object based on the device
func init(player_num: int):
	player = player_num
	var device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)
	team_name = PlayerManager.get_player_data(player_num, "team")


func _physics_process(delta):
	# Jump: Apply impulse upwards. If falling, set speed to 0 before applying
	if input.is_action_just_pressed("jump"):
		summon_bubble()
		if linear_velocity.y > 0:
			set_linear_velocity(Vector2(linear_velocity.x, 0))
		apply_central_impulse(Vector2(0, JUMP_VELOCITY))
	
	# Movement: Apply force according to key pressed. Apply drag.
	var direction = input.get_action_strength("move_right") - input.get_action_strength("move_left")
	apply_central_force(Vector2(direction * SPEED, 0))
	apply_central_force(Vector2(linear_velocity.x * DRAFT, 0))


func _integrate_forces(state):
	# Limit velocity in the x-direction
	if abs(linear_velocity.x) > MAX_SPEED_X:
		state.linear_velocity.x = sign(linear_velocity.x) * MAX_SPEED_X
	# Limit velocity in the y-direction
	if linear_velocity.y > MAX_SPEED_Y_RISING:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED_Y_RISING
	if linear_velocity.y < -MAX_SPEED_Y_FALLING:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED_Y_FALLING
	
	# Allow for instant horizontal movement change
	if input.is_action_just_pressed("move_right") && linear_velocity.x < 0:
		state.linear_velocity.x = 0
	if input.is_action_just_pressed("move_left") && linear_velocity.x > 0:
		state.linear_velocity.x = 0


# Summon a bubble, called upon each jump
func summon_bubble():
	var bubble_instance = BUBBLE_SCENE.instantiate()
	bubble_instance.position = self.position  # Set the bubble's position to the player's position
	bubble_instance.set_team(team_name)
	get_parent().add_child(bubble_instance)  # Add the bubble to the scene tree
	
	# Clear this player's previous bubble (if applicable)
	var players_old_bubble = PlayerManager.get_player_data(player, "current_bubble")
	if players_old_bubble != null and is_instance_valid(players_old_bubble):
		PlayerManager.get_player_data(player, "current_bubble").queue_free()
	PlayerManager.set_player_data(player, "current_bubble", bubble_instance)
