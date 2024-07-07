extends RigidBody2D


const SPEED = 550.0
const JUMP_VELOCITY = -60.0
const DRAFT = -0.75
const MAX_SPEED_X = 200.0
const MAX_SPEED_Y = 300.0


func _physics_process(delta):
	# Jump: Apply impulse upwards. If falling, set speed to 0 before applying
	if Input.is_action_just_pressed("jump"):
		if linear_velocity.y > 0:
			set_linear_velocity(Vector2(linear_velocity.x, 0))
		apply_central_impulse(Vector2(0, JUMP_VELOCITY))
	
	# Movement: Apply force according to key pressed. Apply drag.
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	apply_central_force(Vector2(direction * SPEED, 0))
	apply_central_force(Vector2(linear_velocity.x * DRAFT, 0))


func _integrate_forces(state):
	# Limit velocity in the x-direction
	if abs(linear_velocity.x) > MAX_SPEED_X:
		state.linear_velocity.x = sign(linear_velocity.x) * MAX_SPEED_X
	# Limit velocity in the y-direction
	if abs(linear_velocity.y) > MAX_SPEED_Y:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED_Y
	
