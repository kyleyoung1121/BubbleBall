extends RigidBody2D


@onready var grounded_ray_cast = $GroundedRayCast
@onready var slide_duration_timer = $SlideDurationTimer


const BUBBLE_SCENE = preload("res://scenes-and-scripts/gameplay/bubble.tscn")


const SPEED = 550.0
const JUMP_VELOCITY = -90.0
const DIVE_SPEED = 120
const SLIDE_SPEED = 800
const SLIDE_SPEED_IMPULSE = 150
const EXTRA_GRAVITY = 60
const EXTRA_FALL_SPEED = 20
const DRAFT = -0.75
const MAX_SPEED_X = 500.0
const SOFT_MAX_SPEED_X = 270.0
const MAX_SPEED_Y_RISING = 300.0
const MAX_SPEED_Y_FALLING = 600.0
const BALL_JUMP_RANGE_X = 40.0
const BALL_JUMP_RANGE_Y = 10.0


var team_name = 0
var bounds = {
	"max_x": 640,
	"min_x": 0,
	"max_y": 360,
	"min_y": 0
}
var facing_right = true
var is_sliding = false
var restrict_movement_controls = false
var player: int
var input


# call this function when spawning this player to set up the input object based on the device
func init(player_num: int):
	player = player_num
	var device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)
	team_name = PlayerManager.get_player_data(player_num, "team")
	mass = GameSettings.player_mass


func _physics_process(_delta):
	
	# Update which direction the player is facing
	if input.is_action_just_pressed("move_left"):
		facing_right = false
	elif input.is_action_just_pressed("move_right"):
		facing_right = true
	
	# Jump: Determine which action is appropriate: jump, power jump, slide
	if input.is_action_just_pressed("jump") and not restrict_movement_controls:
		
		# Player is holding down
		if input.is_action_pressed("dive") and grounded_ray_cast.is_colliding():
			handle_start_slide()
		
		# Player is not holding down
		else:
			handle_jump()
			
			# If midair, summon a bubble on jump
			if not grounded_ray_cast.is_colliding():
				summon_bubble()
				play_jump_sound()
				
			# If grounded, apply jump force to nearby ball if applicable
			else:
				handle_power_jump()
	
	# Apply an extra amount of gravity
	apply_central_force(Vector2(0, EXTRA_GRAVITY))
	
	# Apply extra downwards force when falling
	if linear_velocity.y > 0:
		apply_central_force(Vector2(0, EXTRA_FALL_SPEED))
	
	# Dive: Fall faster on command
	if input.is_action_pressed("dive"):
		apply_central_force(Vector2(0, DIVE_SPEED))
	
	if is_sliding:
		# To prevent massive speed transfer into ball, lower mass of player during slide
		mass = 0.2
		# Wane off the force applied as the timer gets lower
		# Equation has been selected arbitrarily. ( x^2 + x ) felt nice.
		var time_decay = (slide_duration_timer.time_left ** 2) + slide_duration_timer.time_left
		if facing_right:
			apply_central_force(Vector2(SLIDE_SPEED * time_decay, 0))
		else:
			apply_central_force(Vector2(-SLIDE_SPEED * time_decay, 0))
	
	
	# Ensure the ground ray cast is always pointing down, regardless of player rotation
	grounded_ray_cast.global_rotation = 0


func handle_jump():
	if GameSettings.jump_mode == 0:
		# Jump normally if not holding down
		if not input.is_action_pressed("dive"):
			# If falling, set speed to 0 before applying
			if linear_velocity.y > 0:
				set_linear_velocity(Vector2(linear_velocity.x, 0))
			# Apply impulse upwards
			apply_central_impulse(Vector2(0, JUMP_VELOCITY))
		
		# If holding down during a jump, boost downwards instead
		else:
			# If rising, set speed to 0 before applying
			if linear_velocity.y < 0:
				set_linear_velocity(Vector2(linear_velocity.x, 0))
			# Apply impulse downwards 
			apply_central_impulse(Vector2(0, JUMP_VELOCITY * -0.5))
	
	# Alternative jump mode (unimplemented)
	# To Do: Instead of jumping up, jump towards where the player is pushing joystick
	else:
		var jump_direction = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("dive") - Input.get_action_strength("jump")
		)
		if jump_direction.length() > 1.0:
			jump_direction = jump_direction.normalized()
		print(jump_direction * JUMP_VELOCITY)
		apply_central_impulse(jump_direction * JUMP_VELOCITY)


func handle_power_jump():
	var ball_instance = get_tree().get_nodes_in_group("ball")[0]
	# If the ball is close to us while we jump from the ground, apply the jump to it too
	if abs(global_position.x - ball_instance.global_position.x) < BALL_JUMP_RANGE_X:
		if abs(global_position.y - ball_instance.global_position.y) < BALL_JUMP_RANGE_Y:
			# Now that we've determined that we are close to the ball,
			# let's find how much force to apply. (Goal: ball jumps about as high as player)
			var ball_mass_ratio = ball_instance.mass / mass
			ball_instance.linear_velocity.y = 0
			ball_instance.apply_central_impulse(Vector2(0, ball_mass_ratio * JUMP_VELOCITY))
			# In addition to jumping, the ball should have a slight horizontal push 
			ball_instance.apply_central_impulse(Vector2(linear_velocity.x * ball_mass_ratio * 0.3, 0))
			SoundManager.play_sound("pjump")
	else:
		play_jump_sound()


func handle_start_slide():
	SoundManager.play_sound("slide")
	# Start the slide with an impulse
	if facing_right:
		apply_central_impulse(Vector2(SLIDE_SPEED_IMPULSE, 0))
	else:
		apply_central_impulse(Vector2(-SLIDE_SPEED_IMPULSE, 0))
	# During the slide, in _physics_process(), we look for this flag and apply more continual force
	is_sliding = true
	slide_duration_timer.start()


func _integrate_forces(state):
	# Limit velocity in the x-direction
	if abs(linear_velocity.x) > MAX_SPEED_X:
		state.linear_velocity.x = sign(linear_velocity.x) * MAX_SPEED_X
	# Limit velocity in the y-direction
	if linear_velocity.y < -MAX_SPEED_Y_RISING:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED_Y_RISING
	if linear_velocity.y > MAX_SPEED_Y_FALLING:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED_Y_FALLING
	
	# Movement: Apply force according to key pressed. Apply drag.
	var direction = input.get_action_strength("move_right") - input.get_action_strength("move_left")
	# Only apply more force if we haven't hit the max speed
	if abs(linear_velocity.x) < SOFT_MAX_SPEED_X:
		apply_central_force(Vector2(direction * SPEED, 0))
	apply_central_force(Vector2(linear_velocity.x * DRAFT, 0))
	
	# Allow for instant horizontal movement change
	if input.is_action_just_pressed("move_right") && linear_velocity.x < 0:
		state.linear_velocity.x = 0
	if input.is_action_just_pressed("move_left") && linear_velocity.x > 0:
		state.linear_velocity.x = 0
	
	# Check for screen wrap
	apply_screen_wrap()


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


func play_jump_sound():
	SoundManager.play_sound("jump")


func apply_screen_wrap():
	if global_position.x > bounds["max_x"]: global_position.x = bounds["min_x"]
	if global_position.x < bounds["min_x"]: global_position.x = bounds["max_x"]
	if global_position.y > bounds["max_y"]: global_position.y = bounds["min_y"]
	if global_position.y < bounds["min_y"]: global_position.y = bounds["max_y"]


func set_bounds(given_bounds):
	bounds = given_bounds


func _on_slide_duration_timer_timeout():
	is_sliding = false
	mass = GameSettings.player_mass
