extends Node2D


# Signal to emit when the bubble should apply an impulse to the ball
signal exploded


# Define the impulse to apply to the ball
const IMPULSE = 30.0


var team_name = null


func _on_body_entered(body):
	if body.is_in_group("ball"):
		# Calculate the direction from the bubble to the ball
		var direction = (body.global_position - global_position).normalized()
		# Apply impulse to the ball
		body.apply_central_impulse(direction * IMPULSE)
		# Remove the bubble from the scene
	queue_free()


func set_team(given_team):
	team_name = given_team
	if given_team == 1: 
		$Area2D.collision_layer = 0b00000001  # Layer 1 (Team 1)
		$Area2D.collision_mask = 0b00000110  # Collide with Layer 2 & 3 (Team 2 & Ball)
	elif given_team == 2:
		$Area2D.collision_layer = 0b00000010  # Layer 2 (Team 2) 
		$Area2D.collision_mask = 0b00000101  # Collide with Layer 1 (Team 1 & Ball)
	else:
		print("Bubble: Invalid team number")
