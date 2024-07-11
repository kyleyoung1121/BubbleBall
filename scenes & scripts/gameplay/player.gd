extends RigidBody2D


@onready var grounded_ray_cast = $GroundedRayCast


const BUBBLE_SCENE = preload("res://scenes & scripts/gameplay/bubble.tscn")


const SPEED = 550.0
const JUMP_VELOCITY = -90.0
const DIVE_SPEED = 120
const EXTRA_GRAVITY = 60
const EXTRA_FALL_SPEED = 20
const DRAFT = -0.75
const MAX_SPEED_X = 270.0
const MAX_SPEED_Y_RISING = 300.0
const MAX_SPEED_Y_FALLING = 600.0
const BALL_JUMP_RANGE_X = 70.0
const BALL_JUMP_RANGE_Y = 10.0


var team_name = 0
var bounds = {
	"max_x": 640,
	"min_x": 0,
	"max_y": 360,
	"min_y": 0
}
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
		# If falling, set speed to 0 before applying
		if linear_velocity.y > 0:
			set_linear_velocity(Vector2(linear_velocity.x, 0))
		# Apply impulse upwards
		apply_central_impulse(Vector2(0, JUMP_VELOCITY))
		# Only summon a bubble mid-air
		if not grounded_ray_cast.is_colliding():
			summon_bubble()
		# If grounded, apply jump force to nearby ball if applicable
		else:
			var ball_instance = get_tree().get_nodes_in_group("ball")[0]
			# If the ball is close to us while we jump from the ground, apply the jump to it too
			if abs(global_position.x - ball_instance.global_position.x) < BALL_JUMP_RANGE_X:
				if abs(global_position.y - ball_instance.global_position.y) < BALL_JUMP_RANGE_Y:
					# Now that we've determined that we are close to the ball,
					# let's find how much force to apply. (Goal: ball jumps about as high as player)
					var ball_mass_ratio = ball_instance.mass / mass
					ball_instance.apply_central_impulse(Vector2(0, ball_mass_ratio * JUMP_VELOCITY))
					# In addition to jumping, the ball should have a slight horizontal push 
					ball_instance.apply_central_impulse(Vector2(linear_velocity.x * ball_mass_ratio * 0.3, 0))
	
	# Apply an extra amount of gravity
	apply_central_force(Vector2(0, EXTRA_GRAVITY))
	
	# Dive: Fall faster on command
	if input.is_action_pressed("dive"):
		apply_central_force(Vector2(0, DIVE_SPEED))
	
	# Apply extra downwards force when falling
	if linear_velocity.y > 0:
		apply_central_force(Vector2(0, EXTRA_FALL_SPEED))
	
	# Movement: Apply force according to key pressed. Apply drag.
	var direction = input.get_action_strength("move_right") - input.get_action_strength("move_left")
	apply_central_force(Vector2(direction * SPEED, 0))
	apply_central_force(Vector2(linear_velocity.x * DRAFT, 0))
	
	# Ensure the ground ray cast is always pointing down, regardless of player rotation
	grounded_ray_cast.global_rotation = 0


func _integrate_forces(state):
	# Limit velocity in the x-direction
	if abs(linear_velocity.x) > MAX_SPEED_X:
		state.linear_velocity.x = sign(linear_velocity.x) * MAX_SPEED_X
	# Limit velocity in the y-direction
	if linear_velocity.y < -MAX_SPEED_Y_RISING:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED_Y_RISING
	if linear_velocity.y > MAX_SPEED_Y_FALLING:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED_Y_FALLING
	
	# Allow for instant horizontal movement change
	if input.is_action_just_pressed("move_right") && linear_velocity.x < 0:
		state.linear_velocity.x = 0
	if input.is_action_just_pressed("move_left") && linear_velocity.x > 0:
		state.linear_velocity.x = 0
	
	# Check for screen wrap
	if global_position.x > bounds["max_x"]: global_position.x = bounds["min_x"]
	if global_position.x < bounds["min_x"]: global_position.x = bounds["max_x"]
	if global_position.y > bounds["max_y"]: global_position.y = bounds["min_y"]
	if global_position.y < bounds["min_y"]: global_position.y = bounds["max_y"]


# Summon a bubble, called upon each jump
func summon_bubble():
	var bubble_instance = BUBBLE_SCENE.instantiate()
	bubble_instance.position = self.position  # Set the bubble's position to the player's position
	bubble_instance.scale = Vector2(GameSettings.bubble_size, GameSettings.bubble_size)
	bubble_instance.set_team(team_name)
	get_parent().add_child(bubble_instance)  # Add the bubble to the scene tree
	
	# Clear this player's previous bubble (if applicable)
	var players_old_bubble = PlayerManager.get_player_data(player, "current_bubble")
	if players_old_bubble != null and is_instance_valid(players_old_bubble):
		PlayerManager.get_player_data(player, "current_bubble").queue_free()
	PlayerManager.set_player_data(player, "current_bubble", bubble_instance)


func set_bounds(given_bounds):
	bounds = given_bounds
