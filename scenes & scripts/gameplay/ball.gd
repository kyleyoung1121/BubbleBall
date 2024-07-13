extends RigidBody2D


signal goal_scored(team)


const MAX_SPEED = 550


var bounds = {
	"max_x": 640,
	"min_x": 0,
	"max_y": 360,
	"min_y": 0
}


func _ready():
	set_contact_monitor(true)  # Enable contact monitoring
	set_max_contacts_reported(5)


func _process(delta):
	var colliding_bodies = get_colliding_bodies()
	
	# Check to see if the ball has collided with a goal
	for body in colliding_bodies:
		if body.is_in_group("goal"):
			# Ask the goal for its team
			var team_name = body.get_team_name()
			# Emit a signal with the team number
			if team_name == 1:
				emit_signal("goal_scored", 1)
			elif team_name == 2:
				emit_signal("goal_scored", 2)


func _integrate_forces(state):
	# Check for screen wrap
	if global_position.x > bounds["max_x"]: global_position.x = bounds["min_x"]
	if global_position.x < bounds["min_x"]: global_position.x = bounds["max_x"]
	if global_position.y > bounds["max_y"]: global_position.y = bounds["min_y"]
	if global_position.y < bounds["min_y"]: global_position.y = bounds["max_y"]
	
	if abs(linear_velocity.x) > MAX_SPEED:
		state.linear_velocity.x = sign(linear_velocity.x) * MAX_SPEED
		print("Speed capped!")
	
	if abs(linear_velocity.y) > MAX_SPEED:
		state.linear_velocity.y = sign(linear_velocity.y) * MAX_SPEED
		print("Speed capped!")


func set_bounds(given_bounds):
	bounds = given_bounds
