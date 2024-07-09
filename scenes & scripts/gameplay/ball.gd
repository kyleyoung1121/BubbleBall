extends RigidBody2D


signal goal_scored(team)


func _ready():
	set_contact_monitor(true)  # Enable contact monitoring
	set_max_contacts_reported(5)


func _process(delta):
	var colliding_bodies = get_colliding_bodies()
	
	# Check to see if the ball has collided with a goal
	for body in colliding_bodies:
		if body.is_in_group("goal"):
			var goal_node = body
			
			# Ask the goal for its team
			var team_name = goal_node.get_team_name()
			
			# Print which goal was scored on
			print("Ball scored on goal of team: ", team_name)
			
			# Emit a signal with the team number
			if team_name == 1:
				emit_signal("goal_scored", 1)
			elif team_name == 2:
				emit_signal("goal_scored", 2)
